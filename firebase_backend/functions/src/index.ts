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
    text += data["assistant_name"] + ": " + data["assistant"] + "\n";
    text += "ME: " + data["user"];

    let system_prompt = `You will rate how good my response to the ${data["assistant_name"]} statement is. Start with either "Great Answer", "Good Answer" or "Poor Answer". Explain why (2-3 points) and provide perfect wording in the langauge of the conversation.`;
    if (data["language"] == "de") {
        system_prompt = `Du wirst bewerten, wie gut meine Antwort auf die ${data["assistant_name"]} Aussage ist. Beginnen Sie mit "Super Antwort", "Gute Antwort" oder "Schlechte Antwort". Erkläre warum (2-3 Punkte) und gib perfekte Formulierung in der Sprache des Dialoges an.`;
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
    functions.logger.info(text);

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


