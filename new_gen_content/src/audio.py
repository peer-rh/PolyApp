import json
import random
from google.cloud import texttospeech
import os
import hashlib

avatar_to_voice = json.load(open("data/settings/avatar_voices.json", "r"))
client = texttospeech.TextToSpeechClient()


def generate_audio(text: str, lang_code: str, avatar: str):
    """
        id is md5("{lang_code}_{avatar}_{text}")
        if vocab lesson use "random" for avatar
    """
    this_id = f"{lang_code}_{avatar}_{text}"
    this_id = hashlib.md5(this_id.encode()).hexdigest()

    if os.path.exists(f"out/cache/{this_id}.mp3"):
        return f"out/cache/{this_id}.mp3"

    voice = None
    if avatar == "random":
        this_avatar = random.choice(list(avatar_to_voice.keys()))
        voice = avatar_to_voice[this_avatar][lang_code]
    else:
        voice = avatar_to_voice[avatar][lang_code]

    input_text = texttospeech.SynthesisInput(text=text)
    voice_conf = texttospeech.VoiceSelectionParams(
        language_code=voice["language_code"],
        name=voice["name"],
    )

    audio_config = texttospeech.AudioConfig(
        pitch=voice["pitch"],
        audio_encoding=texttospeech.AudioEncoding.MP3
    )
    out = client.synthesize_speech(
        input=input_text,
        voice=voice_conf,
        audio_config=audio_config
    )

    with open(f"data/cache/audio/{this_id}.mp3", "wb") as out_file:
        out_file.write(out.audio_content)
