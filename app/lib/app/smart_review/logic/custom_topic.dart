import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/data/lesson_model.dart';
import 'package:poly_app/app/learn_track/data/sub_chapter_model.dart';
import 'package:poly_app/app/learn_track/logic/user_progress_provider.dart';
import 'package:poly_app/app/lessons/ai_chat/data.dart';
import 'package:poly_app/app/lessons/vocab/data.dart';
import 'package:poly_app/common/logic/languages.dart';

Future<String> generateCustomTopic(String prompt, WidgetRef ref) async {
  // TODO: audio not working
  // TODO: Chat not working
  // TOOD: Make chat and subchapter more modular and adaptable to custom topics
  // TOOD: Make Auto capitialization
  final appLang = ref.read(appLangProvider);
  final learnLang = ref.read(learnLangProvider);
  final response =
      await FirebaseFunctions.instance.httpsCallable("generateVocabList").call({
    "msg": prompt,
    "learn_lang": learnLang.englishName,
    "app_lang": appLang.englishName
  });
  final data = response.data;

  final CustomSubchapter id = (
    id: "custom_${ref.read(userLearnTrackProvider).customSubchapters.length}",
    name: data["title"]
  );

  List<LessonMetadataModel> lessonsMeta = [];
  final lessons = data["lessons"];
  for (int i = 0; i < lessons.length; i++) {
    lessonsMeta.add(LessonMetadataModel(
        id: "${id.id}_$i", name: lessons[i]["name"], type: "vocab"));
    final thisLesson = StaticVocabLessonModel(
      id: "${id.id}_i",
      name: lessons[i]["name"],
      vocabList: lessons[i]["phrases"]
          .map<StaticVocabModel>((e) => (
                appLang: e["app_lang"] as String,
                learnLang: e["learn_lang"] as String
              ))
          .toList(),
    );
    ref
        .read(userLearnTrackDocProvider)
        .collection("custom")
        .doc("${id.id}_$i")
        .set(thisLesson.toJson());
  }

  lessonsMeta.add(LessonMetadataModel(
      id: "${id.id}_chat", name: "Specialized Chat", type: "ai_chat"));

  final thisLesson = StaticAIChatLessonModel(
      id: "${id.id}_chat",
      name: "Specialized Chat",
      avatar: "poly",
      startingMsg: learnLang.hello,
      promptDesc: prompt,
      voiceSettings: learnLang.defaultVoice);
  ref
      .read(userLearnTrackDocProvider)
      .collection("custom")
      .doc("${id.id}_chat")
      .set(thisLesson.toJson());

  final sub = SubchapterModel(
      id: id.id, name: id.name, lessons: lessonsMeta, description: prompt);

  await ref
      .read(userLearnTrackDocProvider)
      .collection("custom")
      .doc(id.id)
      .set(sub.toJson());
  ref.read(userLearnTrackProvider).addSubchapter(id);

  return id.id;
}
