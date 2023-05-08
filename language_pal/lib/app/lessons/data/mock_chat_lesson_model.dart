class MockChatLessonModel {
  String id;
  String title;
  String avatar;
  List<MockChatMsgModel> msgList;

  MockChatLessonModel({
    required this.id,
    required this.title,
    required this.avatar,
    required this.msgList,
  });

  factory MockChatLessonModel.fromJson(Map<String, dynamic> json, String id) =>
      MockChatLessonModel(
          id: id,
          title: json["title"],
          avatar: json["content"]["avatar"],
          msgList: json["content"]["msg_list"]
              .map((x) => MockChatMsgModel(
                    appLang: x["app_lang"],
                    learnLang: x["learn_lang"],
                    audioUrl: x["audio_url"],
                    isAi: x["is_ai"],
                  ))
              .toList()
              .cast<MockChatMsgModel>());
}

class MockChatMsgModel {
  String appLang;
  String learnLang;
  String audioUrl;
  bool isAi;

  MockChatMsgModel({
    required this.appLang,
    required this.learnLang,
    required this.audioUrl,
    required this.isAi,
  });
}
