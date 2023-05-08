from dotenv import load_dotenv
import os
import openai
import json
import random
from google.cloud import texttospeech
import uuid
import pickle
from firebase_connector import upload_audio
from json import load, dump

load_dotenv()


def save_cache():
    dump({";".join(k): v for k, v in cache_translate.items()},
         open("out/cache_translate.json", "w"), ensure_ascii=False, indent=4)
    dump({";".join(k): v for k, v in cache_audio.items()},
         open("out/cache_audio.json", "w"), ensure_ascii=False, indent=4)


def load_cache():
    global cache_translate
    global cache_audio
    if os.path.exists("out/cache_translate.json"):
        cache_translate = load(open("out/cache_translate.json", "r"))
        cache_translate = {tuple(k.split(";")): v for k,
                           v in cache_translate.items()}
    if os.path.exists("out/cache_audio.json"):
        cache_audio = load(open("out/cache_audio.json", "r"))
        cache_audio = {tuple(k.split(";")): v for k, v in cache_audio.items()}


### TRANSLATE ###
openai.api_key = os.getenv("OPENAI_KEY")
cache_translate = {}
if os.path.exists("out/translate_cache.pkl"):
    cache_translate = pickle.load(open("out/translate_cache.pkl", "rb"))


def translate(txt: str, lang: str) -> str:
    if lang == "en":
        return txt
    if cache_translate.get((txt, lang)):
        return cache_translate[(txt, lang)]
    completion = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": f"Translate the user prompt into beginner level {lang}. It is important that you only write the result without any additional information."},
            {"role": "user", "content": txt}
        ]
    ).choices[0].message["content"]

    cache_translate[(txt, lang)] = completion

    return completion


### VOICE ###
SKIP_VOICE = False
avatar_to_voice = json.load(open("settings/avatar_voices.json", "r"))
client = texttospeech.TextToSpeechClient()

cache_audio = {}
if os.path.exists("out/cache_audio.pkl"):
    cache_audio = pickle.load(open("out/cache_audio.pkl", "rb"))


def getRandomVoiceSetting(lang: str) -> dict:
    return random.choice(list(avatar_to_voice.values()))[lang]


def generateVoiceUrl(text: str, avatar: str, lang: str) -> str:
    if SKIP_VOICE:
        return ""
    if cache_audio.get((text, avatar, lang)):
        return cache_audio[(text, avatar, lang)]
    voice_settings = None
    if avatar == "random":
        voice_settings = getRandomVoiceSetting(lang)
    else:
        voice_settings = avatar_to_voice[avatar][lang]

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

    cache_audio[(text, avatar, lang)] = f"audio/{this_id}.mp3"
    upload_audio(f"audio/{this_id}.mp3")
    return f"audio/{this_id}.mp3"


### LANG ###
class Lang:
    def __init__(self, code, contry_name, english_name):
        self.code = code
        self.contry_name = contry_name
        self.english_name = english_name


langs = {
    "en": Lang("en", "United States", "English"),
    "de": Lang("de", "Germany", "German"),
    "es": Lang("es", "Spain", "Spanish"),
}


def convert_text(txt: str, learn_lang: str, app_lang) -> str:
    learn_lang = langs[learn_lang]
    app_lang = langs[app_lang]
    txt = txt.replace("{{}}", learn_lang.english_name)
    txt = txt.replace("{}", app_lang.english_name)
    txt = txt.replace("[[]]", learn_lang.contry_name)
    txt = txt.replace("[]", app_lang.contry_name)
    return txt
