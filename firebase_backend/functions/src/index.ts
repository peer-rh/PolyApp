import * as functions from "firebase-functions";

import admin = require('firebase-admin');
admin.initializeApp();

import { Configuration, CreateChatCompletionResponse, OpenAIApi } from "openai";
import { defineSecret } from "firebase-functions/params";

const openAIKey = defineSecret("OPENAI_KEY");

export const getChatGPTResponse = functions.runWith({ secrets: ["OPENAI_KEY"] }).https.onCall(async (data, context) => {
    // Check if current user is allowed to do so
    const uid = context.auth?.uid;
    if (uid == null) throw new functions.https.HttpsError('unauthenticated', "The User must be authorized")
    functions.logger.info("Get getChatGPTResponse called: " + data.toString());

    let system_message = `We are going to do a roleplay in ${data["language"]}. The scenario is: ${data["scenario"]}. Use simple vocabulary and grammar. You must not provide a translation or any additional information. If I have said goodbye end with "[END]"`;

    const configuration = new Configuration({
        apiKey: openAIKey.value(),
    });
    const openai = new OpenAIApi(configuration);
    let new_data: Array<any> = [{ role: "system", content: system_message }].concat(data["messages"]);

    functions.logger.info("Loaded OpenAI API in getAIMsgResponse");
    let comp: CreateChatCompletionResponse = (await openai.createChatCompletion({
        model: "gpt-3.5-turbo",
        max_tokens: 100,
        messages: new_data,
        user: uid,
    })).data
    functions.logger.info("Returning response: " + comp.choices[0].message?.content);
    return comp.choices[0].message?.content;

});

export const getTranslation = functions.runWith({ secrets: ["OPENAI_KEY"] }).https.onCall(async (data, context) => {
    // Check if current user is allowed to do so
    const uid = context.auth?.uid;
    if (uid == null) throw new functions.https.HttpsError('unauthenticated', "The User must be authorized")
    const configuration = new Configuration({
        apiKey: openAIKey.value(),
    });
    const openai = new OpenAIApi(configuration);
    let comp: CreateChatCompletionResponse = (await openai.createChatCompletion({
        model: "gpt-3.5-turbo",
        user: uid,
        max_tokens: 200,
        messages: [
            { role: "system", content: `Translate this sentence into ${data["lang"]}.` },
            { role: "user", content: data["text"] }
        ],

    })).data;
    return comp.choices[0].message?.content;
})

export const getAnswerRating = functions.runWith({ secrets: ["OPENAI_KEY"] }).https.onCall(async (data, context) => {
    // Check if current user is allowed to do so
    const uid = context.auth?.uid;
    if (uid == null) throw new functions.https.HttpsError('unauthenticated', "The User must be authorized")
    let text = "ENVIRONMENT: " + data["environment"] + "\n";
    for (let i = 0; i < data["messages"].length; i++) {
        if (data["messages"][i]["role"] == "assistant") {
            text += data["assistant_name"] + ": " + data["messages"][i]["content"] + "\n";
        } else {
            text += "ME: " + data["messages"][i]["content"] + "\n";
        }
    }
    functions.logger.info("Text: " + text);


    let system_prompt = `Rate my previous last response based on the following criteria: accuracy, grammar (Ignore punctuation and capital letters), conventions, clarity, conciseness and politeness. The result is only "correct" if it meets all these criteria. Provide an explanation, suggestion (how I can improve), a corrected answer for me and one word from the result list. Use this format: "EXPLANATION:...(2 Sentences; Max 18 words) \n SUGGESTION: ...(1 Sentence; ; Max 10 words) \n SUGGESTION_TRANSLATED: ...(in ${data["language"]}) \n CORRECTED_ME: ... \n CORRECTED_ME_TRANSLATED: ... (in ${data["language"]}) \n RESULT:grammar_error/incomplete/unclear/impolite/correct (1 Word)"`;


    const configuration = new Configuration({
        apiKey: openAIKey.value(),
    });
    const openai = new OpenAIApi(configuration);

    let comp: CreateChatCompletionResponse = (await openai.createChatCompletion({
        model: "gpt-3.5-turbo",
        user: uid,
        max_tokens: 200,
        messages: [
            { role: "system", content: system_prompt },
            { role: "user", content: text }
        ],

    })).data;

    functions.logger.info("Response: " + comp.choices[0].message?.content.split("\n"));
    let ans: string[] | undefined = comp.choices[0].message?.content.split("\n");
    if (ans == undefined) {
        throw new functions.https.HttpsError('internal', "Error while splitting answer");
    }
    // Find the Line with EXPLANATION and parse its content
    let explanation = "";
    let suggestion = null;
    let suggestion_translated = null;
    let me_corrected = "";
    let me_corrected_translated = "";
    let result = "";

    for (let i = 0; i < ans.length; i++) {
        if (ans[i].startsWith("EXPLANATION:"))
            explanation = ans[i].substring(12).trim();
        else if (ans[i].startsWith("SUGGESTION:"))
            suggestion = ans[i].substring(11).trim();
        else if (ans[i].startsWith("SUGGESTION_TRANSLATED:"))
            suggestion_translated = ans[i].substring(22).trim();
        else if (ans[i].startsWith("CORRECTED_ME:"))
            me_corrected = ans[i].substring(13).trim();
        else if (ans[i].startsWith("CORRECTED_ME_TRANSLATED:"))
            me_corrected_translated = ans[i].substring(24).trim();
        else if (ans[i].startsWith("RESULT:"))
            result = ans[i].substring(7).trim().replace(".", "").toLowerCase();
    }
    if (suggestion?.toLowerCase().replace(".", "") === "none") {
        suggestion_translated = null;
        suggestion = null;
    }

    if (data["language"] == "english") {
        suggestion_translated = suggestion;
    }

    let ret = {
        explanation: explanation,
        suggestion: suggestion,
        suggestion_translated: suggestion_translated,
        me_corrected: me_corrected,
        me_corrected_translated: me_corrected_translated,
        type: result
    };
    functions.logger.info("Returning: " + JSON.stringify(ret));
    return ret;
})

export const getConversationRating = functions.runWith({ secrets: ["OPENAI_KEY"] }).https.onCall(async (data, context) => {
    // Check if current user is allowed to do so
    const uid = context.auth?.uid;
    if (uid == null) throw new functions.https.HttpsError('unauthenticated', "The User must be authorized")
    let text = "ENVIRONMENT: " + data["environment"] + "\n";
    for (let i = 0; i < data["messages"].length; i++) {
        if (data["messages"][i]["role"] == "assistant") {
            text += data["assistant_name"] + ": " + data["messages"][i]["content"] + "\n";
        } else {
            text += "ME: " + data["messages"][i]["content"] + "\n";
        }
    }
    let system_prompt = `Rate the discussion for me. How well would I probably do in a real life situation.  How well did I achieve my goal of "${data["goal"]}". Give me feedback in ${data["language"]}. Follow the format: "SUGGESTION_1: ... (1 sentence) \n SUGGESTION_2:... (1 sentence) \n SUGGESTION_3: ... (1 sentence) \n OVERALL_SCORE: .../10 \n GOAL_SCORE: .../10"`;

    const configuration = new Configuration({
        apiKey: openAIKey.value(),
    });
    const openai = new OpenAIApi(configuration);

    let comp: CreateChatCompletionResponse = (await openai.createChatCompletion({
        model: "gpt-3.5-turbo",
        user: uid,
        max_tokens: 240,
        messages: [
            { role: "system", content: system_prompt },
            { role: "user", content: text }
        ],

    })).data;
    functions.logger.info("Response: " + comp.choices[0].message?.content);

    let suggestion_1 = "";
    let suggestion_2 = "";
    let suggestion_3 = "";
    let overall_score: number | null = null;
    let goal_score: number | null = null;

    let ans: string[] | undefined = comp.choices[0].message?.content.split("\n");

    if (ans == undefined) {
        throw new functions.https.HttpsError('internal', "Error while splitting answer");
    }

    for (let i = 0; i < ans.length; i++) {
        if (ans[i].startsWith("SUGGESTION_1:"))
            suggestion_1 = ans[i].substring(13).trim();
        else if (ans[i].startsWith("SUGGESTION_2:"))
            suggestion_2 = ans[i].substring(13).trim();
        else if (ans[i].startsWith("SUGGESTION_3:"))
            suggestion_3 = ans[i].substring(13).trim();
        else if (ans[i].startsWith("OVERALL_SCORE:"))
            overall_score = parseInt(ans[i].substring(15).split("/")[0].trim());
        else if (ans[i].startsWith("GOAL_SCORE:"))
            goal_score = parseInt(ans[i].substring(12).split("/")[0].trim());
    }

    return {
        suggestion_1: suggestion_1,
        suggestion_2: suggestion_2,
        suggestion_3: suggestion_3,
        overall_score: overall_score,
        goal_score: goal_score
    };
})

export const generateTextToSpeech = functions.https.onCall(async (data, context) => {
    const textToSpeech = require('@google-cloud/text-to-speech');

    // Check if current user is allowed to do so
    const uid = context.auth?.uid;
    if (uid == null) throw new functions.https.HttpsError('unauthenticated', "The User must be authorized")
    const client = new textToSpeech.TextToSpeechClient();

    const request = {
        input: { text: data["text"] },
        voice: { languageCode: data["language_code"], name: data["voice_name"] },
        audioConfig: { audioEncoding: 'MP3', speakingRate: 0.95, pitch: data["pitch"] },
    };
    const [response] = await client.synthesizeSpeech(request);
    // encode in base64
    return response.audioContent.toString('base64');
});

export const onboardingGetChatGPTResponse = functions.runWith({ secrets: ["OPENAI_KEY"] }).https.onCall(async (data, context) => {
    // Check if current user is allowed to do so
    const uid = context.auth?.uid;
    if (uid == null) throw new functions.https.HttpsError('unauthenticated', "The User must be authorized")
    functions.logger.info("Get getChatGPTResponse called: " + data.toString());

    let system_message = `You'll try to find out what Language the user wants to learn and what the reason for that is. Nothing more. For both only one selection is possible. Stay in the language of the conversation. The Languages are: DE, ES, EN, FR. The Reasons are: WORK, TRAVEL, STUDIES, INTEREST, MOVE. When you have found them out simply write "END: [language] [reason]"`;

    const configuration = new Configuration({
        apiKey: openAIKey.value(),
    });
    const openai = new OpenAIApi(configuration);
    let new_data: Array<any> = [{ role: "system", content: system_message }].concat(data["messages"]);

    let comp: CreateChatCompletionResponse = (await openai.createChatCompletion({
        model: "gpt-3.5-turbo",
        max_tokens: 100,
        messages: new_data,
        user: uid,
    })).data
    functions.logger.info("Returning response: " + comp.choices[0].message?.content);
    let out: String = comp.choices[0].message?.content!;

    if (out.search("END:") != -1) {
        let content = out.split("END:")[0].trim();
        let end = out.split("END:")[1].trim();
        let language = end.split(" ")[0].trim().toLowerCase();
        let reason = end.split(" ")[1].trim().toLowerCase().replace(/[^a-z]/g, '');
        return {
            message: content,
            language: language,
            reason: reason
        }
    }
    return {
        message: out,
    }
});

