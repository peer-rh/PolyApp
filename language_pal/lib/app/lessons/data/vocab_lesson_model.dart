class VocabLessonModel {
  String id;
  String title;
  List<VocabModel> vocabList;
  // TODO: Add Done and errors

  VocabLessonModel({
    required this.id,
    required this.title,
    required this.vocabList,
  });

  factory VocabLessonModel.fromJson(Map<String, dynamic> json, String id) =>
      VocabLessonModel(
          id: id,
          title: json["title"],
          vocabList: json["content"]["vocab_list"]
              .map((x) => VocabModel(
                    appLang: x["app_lang"],
                    learnLang: x["learn_lang"],
                    audioUrl: x["audio_url"],
                  ))
              .toList()
              .cast<VocabModel>());
}

class VocabModel {
  String appLang;
  String learnLang;
  String audioUrl;

  VocabModel({
    required this.appLang,
    required this.learnLang,
    required this.audioUrl,
  });
}
