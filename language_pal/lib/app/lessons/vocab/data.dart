class StaticVocabLessonModel {
  String id;
  String name;
  List<StaticVocabModel> vocabList;

  StaticVocabLessonModel({
    required this.id,
    required this.name,
    required this.vocabList,
  });

  factory StaticVocabLessonModel.fromJson(
          Map<String, dynamic> json, String id) =>
      StaticVocabLessonModel(
          id: id,
          name: json["name"],
          vocabList: json["content"]["vocab"]
              .map((x) => StaticVocabModel(
                    appLang: x["app_lang"],
                    learnLang: x["learn_lang"],
                  ))
              .toList()
              .cast<StaticVocabModel>());
}

class StaticVocabModel {
  String appLang;
  String learnLang;

  StaticVocabModel({
    required this.appLang,
    required this.learnLang,
  });
}
