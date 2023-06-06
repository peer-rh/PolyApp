class StaticVocabLessonModel {
  String id;
  String name;
  List<StaticVocabModel> vocabList;
  bool isCustom;

  StaticVocabLessonModel({
    required this.id,
    required this.name,
    required this.vocabList,
    this.isCustom = false,
  });

  factory StaticVocabLessonModel.fromJson(
          Map<String, dynamic> json, String id, bool isCustom) =>
      StaticVocabLessonModel(
          id: id,
          name: json["name"],
          vocabList: json["content"]["vocab"]
              .map((x) => (
                    appLang: x["app_lang"],
                    learnLang: x["learn_lang"],
                  ))
              .toList()
              .cast<StaticVocabModel>(),
          isCustom: isCustom);

  Map<String, dynamic> toJson() => {
        "name": name,
        "content": {
          "vocab": vocabList
              .map((x) => {
                    "app_lang": x.appLang,
                    "learn_lang": x.learnLang,
                  })
              .toList(),
        },
      };
}

typedef StaticVocabModel = ({
  String learnLang,
  String appLang,
});
