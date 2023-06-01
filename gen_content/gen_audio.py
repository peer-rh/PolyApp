
from src.data import LearnTrackManager, SubChapterManager, LessonManager
import os
from src.translation import Translator
from src.audio import generate_audio
import tqdm

import firebase_admin
from firebase_admin import firestore
from firebase_admin import storage
from firebase_admin import credentials


languages = ["en", "de", "es"]

cred = credentials.Certificate("data/settings/firebase_service.json")
app = firebase_admin.initialize_app(cred,
                                    {'storageBucket': "languagepal-dev.appspot.com"
                                     })

db = firestore.client()
stor = storage.bucket()


if __name__ == "__main__":
    for learn_lang in languages:
        for app_lang in languages:
            if learn_lang == app_lang:
                continue
            ll_trans = Translator(learn_lang)
            al_trans = Translator(app_lang)
            ls = LessonManager()
            for lesson in tqdm.tqdm(ls.lessons.keys()):
                gen = ls.gen_trans(lesson, al_trans, ll_trans)
                if ls.get(lesson).type == "vocab":
                    for v in gen["content"]["vocab"]:
                        generate_audio(v["learn_lang"], learn_lang, "random")
                elif ls.get(lesson).type == "mock_chat":
                    for m in gen["content"]["msg_list"]:
                        generate_audio(m["learn_lang"],
                                       learn_lang, gen["content"]["avatar"])

    for i in tqdm.tqdm(os.listdir("data/cache/audio")):
        if i.endswith(".mp3"):
            # check if already exists
            blob = stor.blob(f"audio/{i}")
            if blob.exists():
                continue
            blob.upload_from_filename(f"data/cache/audio/{i}")
            blob.make_public()
