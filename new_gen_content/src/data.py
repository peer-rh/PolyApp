from src.conv_handlebars import convert_handle_bar
from typing import List
import json
import os
from src import translation
from src.audio import avatar_to_voice

### LearnTrack Data Structure ###


class LearnTrack:
    name: str
    chapters: List = []

    def from_json(self, json):
        self.name = json["name"]
        self.chapters = [Chapter().from_json(chapter)
                         for chapter in json["chapters"]]
        return self

    def to_json(self):
        return {
            "name": self.name,
            "chapter": [chapter.to_json() for chapter in self.chapters]}


class Chapter:
    name: str = ""
    subchapters: List[str] = []

    def from_json(self, json):
        self.name = json["name"]
        self.subchapters = json["subchapters"]
        return self

    def to_json(self):
        return {
            "name": self.name,
            "subchapters": self.subchapters
        }


class LearnTrackManager:
    path = "data/learn_tracks"

    def __init__(self):
        self.learn_tracks = {}
        self.load()

    def load(self):
        for file in os.listdir(self.path):
            if file.endswith(".json"):
                name = file.replace(".json", "")
                self.learn_tracks[name] = LearnTrack().from_json(
                    json.load(open(f"{self.path}/{file}", "r")))

    def get(self, name: str) -> LearnTrack:
        return self.learn_tracks[name]

    def save(self, name: str):
        json.dump(self.learn_tracks[name].to_json(),
                  open(f"{self.path}/{name}.json", "w"))

    def gen_trans(self, name: str, app_lang: translation.Translator) -> dict:
        return {
            "name": app_lang.translate(self.learn_tracks[name].name),
            "chapters": [
                {
                    "name": app_lang.translate(chapter.name),
                    "subchapters": [
                        {
                            "name": app_lang.translate(subchapter_manager.get(sc).name),
                            "id": sc
                        }
                        for sc in chapter.subchapters
                    ]
                }
                for chapter in self.learn_tracks[name].chapters
            ]
        }


### SubChapter Data Structure ###

class SubChapter:
    name: str = ""
    description: str = ""
    lessons: List[str] = []

    def from_json(self, json):
        self.name = json["name"]
        self.description = json["description"]
        self.lessons = json["lessons"]
        return self

    def to_json(self):
        return {
            "name": self.name,
            "description": self.description,
            "lessons": self.lessons
        }


class SubChapterManager:
    path = "data/subchapters"

    def __init__(self):
        self.subchapters = {}
        self.load()

    def load(self):
        for file in os.listdir(self.path):
            if file.endswith(".json"):
                name = file.replace(".json", "")
                self.subchapters[name] = SubChapter().from_json(
                    json.load(open(f"{self.path}/{file}", "r")))

    def get(self, name: str):
        return self.subchapters[name]

    def save(self, name: str):
        json.dump(self.subchapters[name].to_json(),
                  open(f"{self.path}/{name}.json", "w"))

    def gen_trans(self, name: str, app_lang: translation.Translator) -> dict:
        return {
            "name": app_lang.translate(self.subchapters[name].name),
            "description": app_lang.translate(self.subchapters[name].description),
            "lessons": [
                {
                    "name": app_lang.translate(lesson_manager.get(lesson).name),
                    "type": lesson_manager.get(lesson).type,
                    "id": lesson
                }
                for lesson in self.subchapters[name].lessons
            ]
        }


subchapter_manager = SubChapterManager()

### Lesson Data Structure ###


class Lesson:
    type: str = ""
    name: str = ""
    content = {}

    def from_json(self, json):
        self.type = json["type"]
        self.name = json["name"]
        self.content = json["content"]
        return self

    def to_json(self):
        return {
            "type": self.type,
            "name": self.name,
            "content": self.content
        }


class LessonManager:
    path = "data/lessons"

    def __init__(self):
        self.lessons = {}
        self.load()

    def load(self):
        for file in os.listdir(self.path):
            if file.endswith(".json"):
                name = file.replace(".json", "")
                self.lessons[name] = Lesson().from_json(
                    json.load(open(f"{self.path}/{file}", "r")))

    def get(self, name: str):
        return self.lessons[name]

    def save(self, name: str):
        json.dump(self.lessons[name].to_json(),
                  open(f"{self.path}/{name}.json", "w"))

    def gen_trans(self,
                  name: str,
                  app_lang: translation.Translator,
                  learn_lang: translation.Translator,
                  ) -> dict:
        this_lesson = self.lessons[name]
        content = {}
        if self.lessons[name].type == "vocab":
            content = {
                "vocab": [
                    {
                        "learn_lang": learn_lang.translate(
                            convert_handle_bar(vocab, app_lang.code, learn_lang.code)),
                        "app_lang": app_lang.translate(
                            convert_handle_bar(vocab, app_lang.code, learn_lang.code))
                    }
                    for vocab in this_lesson.content["vocab"]
                ]
            }
        if self.lessons[name].type == "mock_chat":
            content = {
                "avatar": this_lesson.content["avatar"],
                "msg_list": [
                    {

                        "learn_lang": learn_lang.translate(
                            convert_handle_bar(msg["msg"], app_lang.code, learn_lang.code)),
                        "app_lang": app_lang.translate(
                            convert_handle_bar(msg["msg"], app_lang.code, learn_lang.code)),
                        "is_ai": msg["is_ai"]
                    }
                    for msg in this_lesson.content["msg_list"]
                ]
            }
        if self.lessons[name].type == "ai_chat":
            content = {
                "avatar": this_lesson.content["avatar"],
                "prompt_desc": this_lesson.content["prompt_desc"],
                "start_msg": learn_lang.translate(
                    this_lesson.content["start_msg"]),
                "voice_settings": avatar_to_voice
                [this_lesson.content["avatar"]]
                [learn_lang.code],

            }

        return {
            "name": app_lang.translate(self.lessons[name].name),
            "type": self.lessons[name].type,
            "content": content,
        }


lesson_manager = LessonManager()
