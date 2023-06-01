import * as functions from "firebase-functions";

import { Configuration, CreateChatCompletionResponse, OpenAIApi } from "openai";
import { defineSecret } from "firebase-functions/params";

const openAIKey = defineSecret("OPENAI_KEY");

export const getChatGPTResponse = functions
    .runWith({ secrets: ["OPENAI_KEY"] })
    .https.onCall(async (data, context) => {
        /*{
            "messages",
            "learn_lang",
            "prompt_desc"
        }*/
        // Check if current user is allowed to do so
        const uid = context.auth?.uid;
        if (uid == null)
            throw new functions.https.HttpsError(
                "unauthenticated",
                "The User must be authorized"
            );
        functions.logger.info("Get getChatGPTResponse called: " + data.toString());

        let system_message = `We are going to do a roleplay in ${data["learn_lang"]}. The scenario is: ${data["prompt_desc"]}. You must not provide a translation or any additional information. If I have said goodbye end with "[END]"`;

        const configuration = new Configuration({
            apiKey: openAIKey.value(),
        });
        const openai = new OpenAIApi(configuration);
        let new_data: Array<any> = [
            { role: "system", content: system_message },
        ].concat(data["messages"]);

        functions.logger.info("Loaded OpenAI API in getAIMsgResponse");
        let comp: CreateChatCompletionResponse = (
            await openai.createChatCompletion({
                model: "gpt-3.5-turbo",
                max_tokens: 100,
                messages: new_data,
                user: uid,
            })
        ).data;
        functions.logger.info(
            "Returning response: " + comp.choices[0].message?.content
        );
        return comp.choices[0].message?.content;
    });

export const getAnswerRating = functions
    .runWith({ secrets: ["OPENAI_KEY"] })
    .https.onCall(async (data, context) => {
        /* {
            "messages",
            "app_lang",
            "learn_lang"
         } */

        // Check if current user is allowed to do so
        const uid = context.auth?.uid;
        if (uid == null)
            throw new functions.https.HttpsError(
                "unauthenticated",
                "The User must be authorized"
            );
        let text = "";
        for (let i = 0; i < data["messages"].length; i++) {
            if (data["messages"][i]["role"] == "assistant") {
                text += "ASSISTANT: " + data["messages"][i]["content"] + "\n";
            } else {
                text += "ME: " + data["messages"][i]["content"] + "\n";
            }
        }

        console.log(text);

        let system_prompt = `You are a teacher, teaching me ${data["learn_lang"]}, by looking over a dialogue between me and your assistant. Rate my previous last response based on the following criteria: 
    - accuracy
    - grammar (Ignore punctuation, accents and capital letters)
    - conventions
    - clarity
    - conciseness
    - politeness. 
The result is only "correct" if it meets all the criteria. Provide:
    - An explanation
    - A Suggestion (how I can improve)
    - A corrected version of my Answer
    - Only One category from the result list
Use this format: 
"explanation:...(2 Sentences; Max 18 words)
suggestion: ...(1 Sentence; Max 10 words; in ${data["app_lang"]})
corrected_me: ... (in ${data["learn_lang"]})
corrected_me_translated: ... (in ${data["appL_lang"]})
result:"grammar_error"/"incomplete"/"unclear"/"impolite"/"correct" (1 Word)"`;

        const configuration = new Configuration({
            apiKey: openAIKey.value(),
        });
        const openai = new OpenAIApi(configuration);

        let comp: CreateChatCompletionResponse = (
            await openai.createChatCompletion({
                model: "gpt-3.5-turbo",
                user: uid,
                max_tokens: 200,
                messages: [
                    { role: "system", content: system_prompt },
                    { role: "user", content: text },
                ],
            })
        ).data;

        functions.logger.info(
            "Response: " + comp.choices[0].message?.content.split("\n")
        );
        let ans: string[] | undefined =
            comp.choices[0].message?.content.split("\n");
        if (ans == undefined) {
            throw new functions.https.HttpsError(
                "internal",
                "Error while splitting answer"
            );
        }
        // Find the Line with EXPLANATION and parse its content
        let explanation = "";
        let suggestion = null;
        let me_corrected = "";
        let me_corrected_translated = "";
        let result = "";

        for (let i = 0; i < ans.length; i++) {
            if (ans[i].startsWith("explanation:"))
                explanation = ans[i].substring(12).trim();
            else if (ans[i].startsWith("suggestion:"))
                suggestion = ans[i].substring(11).trim();
            else if (ans[i].startsWith("corrected_me:"))
                me_corrected = ans[i].substring(13).trim();
            else if (ans[i].startsWith("corrected_me_translated:"))
                me_corrected_translated = ans[i].substring(24).trim();
            else if (ans[i].startsWith("result:"))
                result = ans[i].substring(7).trim().toLowerCase();
            result = result.replace(/[^\w\s\']|_/g, "")
                .replace(/\s+/g, " ");
        }

        let ret = {
            explanation: explanation,
            suggestion: suggestion,
            me_corrected: me_corrected,
            me_corrected_translated: me_corrected_translated,
            type: result,
        };
        functions.logger.info("Returning: " + JSON.stringify(ret));
        return ret;
    });

export const getConversationRating = functions
    .runWith({ secrets: ["OPENAI_KEY"] })
    .https.onCall(async (data, context) => {
        /*{
            app_lang
            messages
            learn_lang
        }*/
        // Check if current user is allowed to do so
        const uid = context.auth?.uid;
        if (uid == null)
            throw new functions.https.HttpsError(
                "unauthenticated",
                "The User must be authorized"
            );
        let text = "";
        for (let i = 0; i < data["messages"].length; i++) {
            if (data["messages"][i]["role"] == "assistant") {
                text +=
                    "assistant: " + data["messages"][i]["content"] + "\n";
            } else {
                text += "me: " + data["messages"][i]["content"] + "\n";
            }
        }
        let system_prompt = `You are a teacher teaching me ${data["learn_lang"]}. Me and your assistant did a roleplay. Tell me what I did well and give me only if applicable up to three things I did wrong in List Format. Be encouraging, very nice and consice (3-4 Sentences). Give your answer in ${data["app_lang"]}`;

        const configuration = new Configuration({
            apiKey: openAIKey.value(),
        });
        const openai = new OpenAIApi(configuration);

        let comp: CreateChatCompletionResponse = (
            await openai.createChatCompletion({
                model: "gpt-3.5-turbo",
                user: uid,
                max_tokens: 240,
                messages: [
                    { role: "system", content: system_prompt },
                    { role: "user", content: text },
                ],
            })
        ).data;
        functions.logger.info("Response: " + comp.choices[0].message?.content);
        return comp.choices[0].message?.content;
    });
