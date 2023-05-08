# TODO: Only assign non computed values

# {} - App Lang english name
# {{}} - Learn Lang english name
# [] - App Lang Country
# [[]] - Learn Lang Country
# /// - Generate audio url
import json
import os
import uuid
from firebase_connector import set_lesson, set_subchapter, set_learn_track
from convert_data import translate, generateVoiceUrl, save_cache, avatar_to_voice, convert_text, load_cache

learn_langs = ["de", "en", "es"]
app_langs = ["en", "de"]


def gen_lessons():
    def store_new_lesson(lesson_name: str, lesson_data: dict, gen_content):
        for al in app_langs:
            for ll in learn_langs:
                new_lesson = {
                    "type": lesson_data["type"],
                    "title": translate(lesson_data["title"], al),
                    "content": gen_content(al, ll)
                }
                set_lesson(lesson_name + "_" + al + "_" + ll, new_lesson)

    def add_ids(items):
        all_ids = []
        for i in range(len(items)):
            msg = items[i]
            if isinstance(msg, str):
                msg = {
                    "id": str(uuid.uuid4()),
                    "content": msg
                }
                items[i] = msg
            all_ids.append(msg["id"])
        return all_ids, items

    def comprehensive_translate(txt: str, al: str, ll: str):
        conv = convert_text(txt, ll, al)
        return translate(conv, al), translate(conv, ll)

    for lesson in os.listdir("in/lessons"):
        print("start lesson: " + lesson + "")
        lesson_data = json.load(open(f"in/lessons/{lesson}", "r"))
        if lesson_data["type"] == "vocab":
            all_ids, lesson_data["content"] = add_ids(lesson_data["content"])
            json.dump(lesson_data, open(
                f"in/lessons/{lesson}", "w"), indent=4, ensure_ascii=False)

            def gen_vocab(i, al, ll):
                al_tran, ll_tran = comprehensive_translate(
                    i["content"], al, ll)
                return {
                    "id": i["id"],
                    "app_lang": al_tran,
                    "learn_lang": ll_tran,
                    "audio_url": generateVoiceUrl(ll_tran, "random", ll),
                }
            store_new_lesson(lesson.split(".")[0], lesson_data, lambda al, ll: {
                "vocab_list": [
                    gen_vocab(i, al, ll) for i in lesson_data["content"]
                ]})
        elif lesson_data["type"] == "mock_chat":
            all_ids, lesson_data["content"] = add_ids(lesson_data["content"])
            json.dump(lesson_data, open(
                f"in/lessons/{lesson}", "w"), indent=4, ensure_ascii=False)
            isAi = lesson_data["starts_with_ai"]

            def gen_msg(i, al, ll):
                nonlocal isAi
                isAi = not isAi
                al_tran, ll_tran = comprehensive_translate(
                    i["content"], al, ll)
                return {
                    "id": i["id"],
                    "is_ai": not isAi,
                    "app_lang": al_tran,
                    "learn_lang": ll_tran,
                    "audio_url": generateVoiceUrl(ll_tran, lesson_data["avatar"], ll),
                }

            store_new_lesson(lesson.split(".")[0], lesson_data, lambda al, ll: {
                "avatar": lesson_data["avatar"],
                "msg_list": [
                    gen_msg(i, al, ll) for i in lesson_data["content"]
                ]})

        elif lesson_data["type"] == "ai_chat":
            store_new_lesson(lesson.split(".")[0], lesson_data, lambda al, ll: {
                "avatar": lesson_data["avatar"],
                "voice_settings": avatar_to_voice[lesson_data["avatar"]][ll],
                "prompt_desc": lesson_data["prompt_desc"],
                "goal_desc": lesson_data["goal_desc"],
                "starting_msg": comprehensive_translate(lesson_data["starting_msg"], al, ll)[0],
            })


def gen_subchapters():
    for subchap in os.listdir("in/subchapters"):
        print("start subchapter: " + subchap + "")

        def gen_lesson_meta(i, al, ll):
            lesson_data = json.load(open(f"in/lessons/{i}.json", "r"))
            return {
                "id": f"{i}_{al}_{ll}",
                "title": translate(lesson_data["title"], al),
                "type": lesson_data["type"]
            }

        subchap_data = json.load(open(f"in/subchapters/{subchap}", "r"))
        for al in app_langs:
            for ll in learn_langs:
                set_subchapter(subchap.split(".")[0] + "_" + al + "_" + ll, {
                    "title": translate(subchap_data["title"], al),
                    "description": translate(subchap_data["description"], al),
                    "lessons": list(map(lambda x: gen_lesson_meta(x, al, ll),
                                        subchap_data["lessons"]))
                })


def gen_tracks():
    for track in os.listdir("in/tracks"):
        print("start track: " + track + "")

        def gen_subchapter_meta(i, al, ll):
            subchap_data = json.load(open(f"in/subchapters/{i}.json", "r"))
            return {
                "id": f"{i}_{al}_{ll}",
                "title": translate(subchap_data["title"], al),
            }

        track_data = json.load(open(f"in/tracks/{track}", "r"))
        for al in app_langs:
            for ll in learn_langs:
                set_learn_track(track.split(".")[0] + "_" + al + "_" + ll, {
                    "chapters": [
                        {
                            "title": chap["title"],
                            "subchapters": list(map(lambda x: gen_subchapter_meta(x, al, ll), chap["subchapters"]))
                        }
                        for chap in track_data["chapters"]
                    ]
                })


if __name__ == "__main__":
    if (not os.path.exists("out")):
        os.mkdir("out")
        os.mkdir("out/audio")

    load_cache()

    gen_lessons()
    gen_subchapters()
    gen_tracks()
    save_cache()
    # gen_subchapter(al, ll)
    # gen_track(al, ll)
