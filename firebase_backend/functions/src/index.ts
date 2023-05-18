import * as functions from "firebase-functions";

import admin = require("firebase-admin");
admin.initializeApp();

import { Configuration, CreateChatCompletionResponse, OpenAIApi } from "openai";
import { defineSecret } from "firebase-functions/params";

const openAIKey = defineSecret("OPENAI_KEY");

export {
    getChatGPTResponse,
    getAnswerRating,
    getConversationRating,
} from "./chat_flow";

export const translate = functions
    .runWith({ secrets: ["OPENAI_KEY"] })
    .https.onCall(async (data, context) => {
        /*{
          target
          text
        }*/
        // Check if current user is allowed to do so
        const uid = context.auth?.uid;
        if (uid == null)
            throw new functions.https.HttpsError(
                "unauthenticated",
                "The User must be authorized"
            );
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
                    {
                        role: "system",
                        content: `Translate this sentence into ${data["target"]}.`,
                    },
                    { role: "user", content: data["text"] },
                ],
            })
        ).data;
        return comp.choices[0].message?.content;
    });

export const text2Speech = functions.https.onCall(async (data, context) => {
    /*{
        text
        language_code
        voice_name
        pitch
      }*/
    const textToSpeech = require("@google-cloud/text-to-speech");

    // Check if current user is allowed to do so
    const uid = context.auth?.uid;
    if (uid == null)
        throw new functions.https.HttpsError(
            "unauthenticated",
            "The User must be authorized"
        );
    const client = new textToSpeech.TextToSpeechClient();

    const request = {
        input: { text: data["text"] },
        voice: { languageCode: data["language_code"], name: data["voice_name"] },
        audioConfig: {
            audioEncoding: "MP3",
            speakingRate: 0.95,
            pitch: data["pitch"],
        },
    };
    const [response] = await client.synthesizeSpeech(request);
    // encode in base64
    return response.audioContent.toString("base64");
});

export const onboardingGetChatGPTResponse = functions
    .runWith({ secrets: ["OPENAI_KEY"] })
    .https.onCall(async (data, context) => {
        /*{
          messages
        }*/
        // Check if current user is allowed to do so
        const uid = context.auth?.uid;
        if (uid == null)
            throw new functions.https.HttpsError(
                "unauthenticated",
                "The User must be authorized"
            );
        functions.logger.info("Get getChatGPTResponse called: " + data.toString());

        let system_message = `You'll try to find out what Language the user wants to learn and what the reason for that is. Nothing more. For both only one selection is possible. Stay in the language of the conversation. The Languages are: "de", "es", "en", "fr". The Reasons are: "work", "travel", "studies", "interest", "move". When you have found them out simply write "END: [language] [reason]"`;

        const configuration = new Configuration({
            apiKey: openAIKey.value(),
        });
        const openai = new OpenAIApi(configuration);
        let new_data: Array<any> = [
            { role: "system", content: system_message },
            ...data["messages"],
        ];

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
        let out: String = comp.choices[0].message?.content!;

        if (out.search("END:") != -1) {
            let content = out.split("END:")[0].trim();
            let end = out.split("END:")[1].trim();
            let language = end.split(" ")[0].trim().toLowerCase();
            let reason = end
                .split(" ")[1]
                .trim()
                .toLowerCase()
                .replace(/[^a-z]/g, "");
            return {
                message: content,
                language: language,
                reason: reason,
            };
        }
        return {
            message: out,
        };
    });

export const getWhisperPronounciationResult = functions
    .runWith({ secrets: ["OPENAI_KEY"] })
    .https.onCall(async (data, context) => {
        /*{
          data
          text
          language
        }*/
        const fs = require("fs");
        const os = require("os");

        // Check if current user is allowed to do so
        const uid = context.auth?.uid;
        if (uid == null)
            throw new functions.https.HttpsError(
                "unauthenticated",
                "The User must be authorized"
            );

        const configuration = new Configuration({
            apiKey: openAIKey.value(),
        });
        const openai = new OpenAIApi(configuration);
        const file_path = os.tmpdir() + "/audio.m4a";
        console.log(file_path);
        fs.writeFileSync(file_path, Buffer.from(data["data"], "base64"));
        const response = await openai.createTranscription(
            fs.createReadStream(file_path),
            "whisper-1",
            `The user is trying to say: ${data["text"]}`,
            undefined,
            undefined,
            data["language"]
        );

        let result = response.data;
        return result["text"];
    });
