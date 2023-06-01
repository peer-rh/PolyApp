"""
{
    "en": {"translation": "...", "approved": false/true }
}
"""
import json
import openai
import os
from dotenv import load_dotenv

load_dotenv()
openai.api_key = os.getenv("OPENAI_KEY")


class Translator:
    def __init__(self, code: str):
        self.cache = {}
        self.code = code
        self.path = f"data/cache/translations_{self.code}.json"
        self.load()

    def load(self):
        if not os.path.exists(self.path):
            self.cache = {}
            return
        with open(self.path, 'r') as f:
            self.cache = json.load(f)

    def save(self):
        if self.code == "en":
            return
        with open(self.path, 'w') as f:
            json.dump(self.cache, f, indent=4,
                      ensure_ascii=False, sort_keys=True)

    def get_trans_that_need_approval(self) -> dict:
        return {x: self.cache[x]
                for x in self.cache.keys() if not self.cache[x]["approved"]}

    def set_trans(self, key: str, value: str):
        self.cache[key] = {"translation": value, "approved": True}
        self.save()

    def gen_translate(self, phrases: list):
        to_gen = []
        for phrase in phrases:
            if phrase not in self.cache:
                to_gen.append(phrase)

        if len(to_gen) != 0:
            self.call_openai(to_gen)
        self.save()

    def call_openai(self, phrases: list):
        text = "\n".join(phrases)
        if self.code == "en":
            return text
        completion = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system",
                    "content": f"Translate the following phrases into {self.code}. Seperate each phrase with a new line."},
                {"role": "user", "content": text}
            ]
        ).choices[0].message["content"]

        for (a, b) in zip(phrases, completion.split("\n")):
            self.cache[a] = {"translation": b, "approved": False}
        return completion.split("\n")

    def translate(self, phrase: str):
        if self.code == "en":
            return phrase
        if phrase in self.cache:
            if not self.cache[phrase]["approved"]:
                print(f"Translation for '{phrase}' not approved yet")
            return self.cache[phrase]["translation"]
