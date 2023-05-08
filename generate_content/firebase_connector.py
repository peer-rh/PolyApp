import firebase_admin
from firebase_admin import firestore
from firebase_admin import storage
from firebase_admin import credentials

cred = credentials.Certificate("settings/firebase_service.json")
app = firebase_admin.initialize_app(cred,
                                    {'storageBucket': "languagepal-dev.appspot.com"
                                     })

db = firestore.client()
stor = storage.bucket()


def set_learn_track(track: str, data: dict):
    db.collection("learn_tracks").document(track).set(data)


def set_subchapter(name: str, data: dict) -> str:
    db.collection("subchapters").document(name).set(data)


def set_lesson(name: str, data: dict) -> str:
    db.collection("lessons").document(name).set(data)


def upload_audio(path: str):
    blob = stor.blob(path)
    blob.upload_from_filename(f"out/{path}")
    blob.make_public()
