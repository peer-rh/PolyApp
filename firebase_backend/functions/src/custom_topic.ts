import * as functions from "firebase-functions";

import { Configuration, OpenAIApi } from "openai";
import { defineSecret } from "firebase-functions/params";

const openAIKey = defineSecret("OPENAI_KEY");

export const generateVocabList = functions
    .runWith({ secrets: ["OPENAI_KEY"] })
    .https.onCall(async (data, context) => {
        /*{
            "msg",
            "learn_lang",
            "app_lang"
        }*/
        // Check if current user is allowed to do so
        const uid = context.auth?.uid;
        if (uid == null)
            throw new functions.https.HttpsError(
                "unauthenticated",
                "The User must be authorized"
            );
        functions.logger.info("Get getChatGPTResponse called: " + data.toString());

        let system_message = `You will generate a list of vocabulary and important phrases for the user who is trying to learn spanish. Follow exactly the format :
TITLE: {{1-3 Words}}

LESSON: {{name}}
- {{${data["learn_lang"]}}}; {{${data["app_lang"]}}}\n" 

Generate 2-3 lessons with at most 10 phrases`;

        const configuration = new Configuration({
            apiKey: openAIKey.value(),
        });
        const openai = new OpenAIApi(configuration);
        let new_data: Array<any> = [
            { role: "system", content: system_message },
            { role: "user", content: data["msg"] },
        ];
        functions.logger.info("Loaded OpenAI API in getAIMsgResponse");
        let ans = (
            await openai.createChatCompletion({
                model: "gpt-3.5-turbo",
                max_tokens: 100,
                messages: new_data,
                user: uid,
            })
        ).data.choices[0].message?.content.split("\n");

        if (ans == undefined) {
            throw new functions.https.HttpsError(
                "internal",
                "Error while splitting answer"
            );
        }

        let title = "";
        let lessons = [];
        let current_lesson: any = null;
        for (let i = 0; i < ans.length; i++) {
            let this_ans_parse = ans[i].toLowerCase();
            if (this_ans_parse.startsWith("title:")) {
                title = this_ans_parse.split(":")[1].trim();
            }

            if (this_ans_parse.startsWith("lesson:")) {
                if (current_lesson) {
                    lessons.push(current_lesson);
                }
                current_lesson = { "name": this_ans_parse.split(":")[1].trim(), "phrases": [] };
            }
            if (this_ans_parse.startsWith("-")) {
                let learn_lang = this_ans_parse.split(";")[0].split("-")[1].trim();
                let app_lang = this_ans_parse.split(";")[1].trim();
                if (current_lesson) {
                    current_lesson["phrases"].push({ "learn_lang": learn_lang, "app_lang": app_lang });
                }
            }

        }
        return {
            title: title,
            lessons: lessons
        };
    });
