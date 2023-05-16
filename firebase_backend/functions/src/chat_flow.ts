import * as functions from "firebase-functions";

import admin = require("firebase-admin");
admin.initializeApp();

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

    let system_message = `We are going to do a roleplay in ${data["learn_lang"]}. The scenario is: ${data["prompt_desc"]}. Use simple vocabulary and grammar. You must not provide a translation or any additional information. If I have said goodbye end with "[END]"`;

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
        "prompt_desc",
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

    let system_prompt = `You are a teacher, teaching me ${data["learn_lang"]}, by looking over a dialogue between me and your assistant. ${data["prompt_desc"]}. Rate my previous last response based on the following criteria: 
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
"EXPLANATION:...(2 Sentences; Max 18 words)
SUGGESTION: ...(1 Sentence; ; Max 10 words)
SUGGESTION_TRANSLATED: ...(in ${data["app_lang"]})
CORRECTED_ME: ... (in ${data["learn_lang"]})
CORRECTED_ME_TRANSLATED: ... (in ${data["appL_lang"]})
RESULT:"grammar_error"/"incomplete"/"unclear"/"impolite"/"correct" (1 Word)"`;

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
        prompt_desc
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
          data["assistant_name"] + ": " + data["messages"][i]["content"] + "\n";
      } else {
        text += "ME: " + data["messages"][i]["content"] + "\n";
      }
    }
    let system_prompt = `You are a teacher teaching me ${data["learn_lang"]}. Me and your assistant did a roleplay, where: ${data["prompt_desc"]}. Tell me what I did well and give me three things I could improve. Be encouraging and very nice. Give your answer in ${data["learn_lang"]}`;

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

    let suggestion_1 = "";
    let suggestion_2 = "";
    let suggestion_3 = "";
    let overall_score: number | null = null;
    let goal_score: number | null = null;

    let ans: string[] | undefined =
      comp.choices[0].message?.content.split("\n");

    if (ans == undefined) {
      throw new functions.https.HttpsError(
        "internal",
        "Error while splitting answer"
      );
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
      goal_score: goal_score,
    };
  });
