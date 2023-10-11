import os
from src.translation import Translator

if __name__ == "__main__":
    lang_code = input("Select language code:")
    # check if path exists
    if os.path.exists(f"data/cache/translations_{lang_code}.json"):
        trans = Translator(lang_code)
        for i, j in trans.get_trans_that_need_approval().items():
            correct = input(f"{i} -> {j['translation']}: ")
            if correct == "":
                trans.set_trans(i, j["translation"])
            else:
                trans.set_trans(i, correct)
    else:
        print("Language code not found")
        exit()
