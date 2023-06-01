import src.data as data
from src.translation import Translator
from src.conv_handlebars import convert_handle_bar
import tqdm

languages = ["en", "de", "es"]

if __name__ == "__main__":
    lt = data.LearnTrackManager()
    sb = data.SubChapterManager()
    ls = data.LessonManager()
    for learn_lang in languages:
        trans = Translator(learn_lang)
        for learn_track in tqdm.tqdm(lt.learn_tracks.values()):
            for chap in learn_track.chapters:
                trans.gen_translate([chap.name])

        for subchapter in tqdm.tqdm(sb.subchapters.values()):
            trans.gen_translate([subchapter.name, subchapter.description])

        for app_lang in languages:
            for lesson in tqdm.tqdm(ls.lessons.values()):
                if lesson.type == "vocab":
                    phrases = [convert_handle_bar(
                        v, app_lang, learn_lang)
                        for v in lesson.content["vocab"]] + [lesson.name]
                    trans.gen_translate(phrases)
                elif lesson.type == "mock_chat":
                    phrases = [convert_handle_bar(
                        m["msg"], app_lang, learn_lang) for m in lesson.content["msg_list"]] + [lesson.name]
                    trans.gen_translate(phrases)
                elif lesson.type == "ai_chat":
                    trans.gen_translate(
                        [lesson.content["start_msg"], lesson.name])
