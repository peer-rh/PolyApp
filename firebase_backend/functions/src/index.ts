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

    const configuration = new Configuration({
        apiKey: openAIKey.value(),
    });
    const openai = new OpenAIApi(configuration);

    functions.logger.info("Loaded OpenAI API in getAIMsgResponse");
    let comp: CreateChatCompletionResponse = (await openai.createChatCompletion({
        model: "gpt-3.5-turbo",
        max_tokens: 100,
        messages: data,
        user: uid,
    })).data
    functions.logger.info("Returning response");
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
            { role: "system", content: `You will translate this sentence into ${data["lang"]}. Give 2 Options.` },
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



    let system_prompt = `Rate my previous last response based on the following criteria: accuracy, grammar (Ignore punctuation and capital letters), conventions, clarity, conciseness and politeness. The result is only "correct" if it meets all these criteria. Provide an explanation,  suggestion (how I can improve), and one word from the result list. Use this format: "EXPLANATION:...(2 Sentences; Max 18 words) \n SUGGESTION: ...(1 Sentence; ; Max 10 words) \n SUGGESTION_TRANSLATED: ...(1 Sentence; Max 10 words; in ${data["language"]}) RESULT:grammar_error/incomplete/unclear/impolite/correct (1 Word)"`;

    const configuration = new Configuration({
        apiKey: openAIKey.value(),
    });
    const openai = new OpenAIApi(configuration);

    let comp: CreateChatCompletionResponse = (await openai.createChatCompletion({
        model: "gpt-3.5-turbo",
        user: uid,
        max_tokens: 120,
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
    let result = "";

    for (let i = 0; i < ans.length; i++) {
        if (ans[i].startsWith("EXPLANATION:"))
            explanation = ans[i].substring(12).trim();
        else if (ans[i].startsWith("SUGGESTION:"))
            suggestion = ans[i].substring(11).trim();
        else if (ans[i].startsWith("SUGGESTION_TRANSLATED:"))
            suggestion_translated = ans[i].substring(22).trim();
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

    return {
        explanation: explanation,
        suggestion: suggestion,
        suggestion_translated: suggestion_translated,
        result: result
    };
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

    let system_prompt = `You will rate how good I performed in this conversation. Give 4-5 Tips in Bulletpoints. End with "Rating: .../100" where you will give a final performance rating from 1 to 100. 100 means perfect fluency.`;
    if (data["language"] == "de") {
        system_prompt = `Du wirst bewerten wie gut ich in diesem Gespräch performt habe. Gib 4-5 Tipps in Stichpunkten. Ende mit "Bewertung: .../100" wo du eine finale Bewertung von 1 bis 100 gibst. 100 bedeutet perfektes Verständins.`;
    }
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
    return comp.choices[0].message?.content;
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


