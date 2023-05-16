class StaticVocabLessonModel {
  String id;
  String title;
  List<StaticVocabModel> vocabList;
  // TODO: Add Done and errors

  StaticVocabLessonModel({
    required this.id,
    required this.title,
    required this.vocabList,
  });

  factory StaticVocabLessonModel.fromJson(
          Map<String, dynamic> json, String id) =>
      StaticVocabLessonModel(
          id: id,
          title: json["title"],
          vocabList: json["content"]["vocab_list"]
              .map((x) => StaticVocabModel(
                    id: x["id"],
                    appLang: x["app_lang"],
                    learnLang: x["learn_lang"],
                    audioUrl: x["audio_url"],
                  ))
              .toList()
              .cast<StaticVocabModel>());
}

class StaticVocabModel {
  String appLang;
  String learnLang;
  String audioUrl;
  String id;

  StaticVocabModel({
    required this.id,
    required this.appLang,
    required this.learnLang,
    required this.audioUrl,
  });
}
