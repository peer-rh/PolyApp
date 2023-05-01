# {} - App Lang english name
# {{}} - Learn Lang english name
# [] - App Lang Country
# [[]] - Learn Lang Country
# /// - Generate audio url
import json
import random
import deepl
import os
from google.cloud import texttospeech
import uuid

SKIP_VOICE = True

avatar_to_voice = {
    "man": {
        "de": {
            "name": "de-DE-Neural2-B",
            "language_code": "de-DE",
            "pitch": -4
        },
        "en": {
            "name": "en-US-Neural2-A",
            "language_code": "en-US",
            "pitch": -4
        },
        "es": {
            "name": "es-ES-Neural2-B",
            "language_code": "es-ES",
            "pitch": -4
        }
    },
    "woman": {
        "de": {
            "name": "de-DE-Neural2-F",
            "language_code": "de-DE",
            "pitch": 0
        },
        "en": {
            "name": "en-US-Neural2-F",
            "language_code": "en-US",
            "pitch": 0
        },
        "es": {
            "name": "es-ES-Neural2-D",
            "language_code": "es-ES",
            "pitch": 0
        }
    }
}


class Lang:
    def __init__(self, code, contry_name, english_name):
        self.code = code
        self.contry_name = contry_name
        self.english_name = english_name


translator = deepl.Translator(
    auth_key="32aa29e2-c61e-8085-14b1-b448e7dcf353:fx")
cache_translate = {}


def translate(text: str, lang: str) -> str:
    if cache_translate.get((text, lang)):
        return cache_translate[(text, lang)]
    if lang == "en":
        lang = "EN-US"
    result = translator.translate_text(text, target_lang=lang)
    cache_translate[(text, lang)] = result.text
    return result.text


def getRandomVoiceSetting(lang: str) -> dict:
    return random.choice(list(avatar_to_voice.values()))[lang]


client = texttospeech.TextToSpeechClient()
cache_audio = {}


def generateVoiceUrl(text: str, voice_settings: dict) -> str:
    if SKIP_VOICE:
        return ""
    if cache_audio.get((text, voice_settings)):
        return cache_audio[text]
    input_text = texttospeech.SynthesisInput(text=text)
    voice = texttospeech.VoiceSelectionParams(
        language_code=voice_settings["language_code"],
        name=voice_settings["name"],
    )

    audio_config = texttospeech.AudioConfig(
        pitch=voice_settings["pitch"],
        audio_encoding=texttospeech.AudioEncoding.MP3
    )
    out = client.synthesize_speech(
        input=input_text,
        voice=voice,
        audio_config=audio_config
    )

    this_id = str(uuid.uuid4())

    with open(f"out/audio/{this_id}.mp3", "wb") as out_file:
        out_file.write(out.audio_content)

    cache_audio[(text, voice_settings)] = f"audio/{this_id}.mp3"
    return f"audio/{this_id}.mp3"


def convertToFinal(data: dict, app_lang: Lang, learn_lang: Lang) -> dict:
    data = data.copy()

    def convLang(txt: str) -> str:
        txt = txt.replace("{{}}", learn_lang.english_name)
        txt = txt.replace("{}", app_lang.english_name)
        txt = txt.replace("[[]]", learn_lang.contry_name)
        txt = txt.replace("[]", app_lang.contry_name)
        return txt

    for chap in data:
        chap["id"] = str(uuid.uuid4())
        for subchap in chap["items"]:
            subchap["id"] = str(uuid.uuid4())
            for item in subchap["items"]:
                item["id"] = str(uuid.uuid4())
                if (item["type"] == "vocab"):
                    for i in range(len(item["items"])):
                        vocab = item["items"][i]
                        vocab = convLang(vocab)
                        learn_lang_translated = translate(
                            vocab, learn_lang.code)
                        item["items"][i] = {
                            "id": str(uuid.uuid4()),
                            "app_lang": translate(vocab, app_lang.code),
                            "learn_lang": learn_lang_translated,
                            "audio_url": generateVoiceUrl(
                                learn_lang_translated,
                                getRandomVoiceSetting(learn_lang.code),
                            ),
                        }

                elif (item["type"] == "mock_chat"):
                    isAI = item["starts_with_ai"]
                    for i in range(len(item["items"])):
                        vocab = item["items"][i]
                        vocab = convLang(vocab)
                        learn_lang_translated = translate(
                            vocab, learn_lang.code)
                        item["items"][i] = {
                            "id": str(uuid.uuid4()),
                            "type": "ai" if (isAI) else "user",
                            "app_lang": translate(vocab, app_lang.code),
                            "learn_lang": learn_lang_translated,
                            "audio_url": generateVoiceUrl(
                                learn_lang_translated,
                                avatar_to_voice[item["avatar"]
                                                ][learn_lang.code],
                            ),
                        }
                        isAI = not isAI

                elif (item["type"] == "ai_chat"):
                    item["starting_msg"] = translate(
                        convLang(item["starting_msg"]), learn_lang.code)
                    item["prompt_desc"] = convLang(item["prompt_desc"])
                    item["goal_desc"] = convLang(item["goal_desc"])
                    item["voice_info"] = avatar_to_voice[item["avatar"]
                                                         ][learn_lang.code]

    return data


learn_langs = [
    Lang("en", "United States", "English"),
    Lang("de", "Germany", "German"),
    Lang("es", "Spain", "Spanish"),
]

app_langs = [
    Lang("en", "United States", "English"),
    Lang("de", "Germany", "German"),
]

if __name__ == "__main__":
    if (os.path.exists("out")):
        import shutil
        shutil.move("out", "out_old")

    os.mkdir("out")
    os.mkdir("out/audio")

    scenario = "travel"
    app_lang = Lang("en", "United States", "English")
    final_out = {}
    for app_lang in app_langs:
        for learn_lang in learn_langs:
            data = json.load(open(f"in/{scenario}.json", "r"))
            out = convertToFinal(data, app_lang, learn_lang)
            final_out[f"{scenario}_{app_lang.code}_{learn_lang.code}"] = out
    json.dump(final_out, open(
        "out/generated.json", "w"),
        ensure_ascii=False)
