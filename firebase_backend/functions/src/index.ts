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
    let user_doc = admin.firestore().collection("users").doc(uid);
    let user_data = await user_doc.get();
    let dM = user_data.get("dailyMsgCount");
    if (dM > 40) throw new functions.https.HttpsError('failed-precondition', "The user has used up all of his messages.");

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
    user_doc.update({ "dailyMsgCount": dM + 1 });
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

    const configuration = new Configuration({
        apiKey: openAIKey.value(),
    });
    const openai = new OpenAIApi(configuration);

    let comp: CreateChatCompletionResponse = (await openai.createChatCompletion({
        model: "gpt-3.5-turbo",
        user: uid,
        max_tokens: 200,
        messages: [
            { role: "system", content: `You will only respond in ${data["language"]}! You will rate how good my response to the ${data["assistant_name"]} statement is. Start with either "${data["great"]}", "${data["good"]}" or "${data["poor"]}". Explain why (2-3 points) and provide perfect wording.` },
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

export const resetMsgDaily = functions.pubsub.schedule("0 0 * * *").timeZone('Europe/Berlin').onRun((_) => {
    admin.firestore().collection("users").where("dailyMsgCount", '!=', 0).get().then((query) => {
        query.forEach(
            (doc) => {
                console.log(doc)
                doc.ref.update({
                    "dailyMsgCount": 0
                })
            }
        )
        return;
    })
})
