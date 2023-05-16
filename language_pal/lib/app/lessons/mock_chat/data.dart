import 'package:poly_app/app/lessons/common/input/data.dart';

class MockChatMsg {
  bool isAi;
  String learnLang;
  String appLang;
  InputStep? step;
  String audioUrl;

  MockChatMsg(this.learnLang, this.appLang, this.isAi, this.audioUrl,
      {this.step});

  factory MockChatMsg.fromJson(Map<String, dynamic> json) {
    return MockChatMsg(
        json['learnLang'], json['appLang'], json['isAi'], json['audioUrl'],
        step: json['inputStep'] != null
            ? InputStep.fromJson(json['inputStep'])
            : null);
  }

  Map<String, dynamic> toJson() {
    return {
      "learnLang": learnLang,
      "appLang": appLang,
      "isAi": isAi,
      "audioUrl": audioUrl,
      "inputStep": step?.toJson(),
    };
  }
}

class StaticMockChatLessonModel {
  String id;
  String title;
  String avatar;
  List<StaticMockChatMsgModel> msgList;

  StaticMockChatLessonModel({
    required this.id,
    required this.title,
    required this.avatar,
    required this.msgList,
  });

  factory StaticMockChatLessonModel.fromJson(
          Map<String, dynamic> json, String id) =>
      StaticMockChatLessonModel(
          id: id,
          title: json["title"],
          avatar: json["content"]["avatar"],
          msgList: json["content"]["msg_list"]
              .map((x) => StaticMockChatMsgModel(
                    appLang: x["app_lang"],
                    learnLang: x["learn_lang"],
                    audioUrl: x["audio_url"],
                    isAi: x["is_ai"],
                  ))
              .toList()
              .cast<StaticMockChatMsgModel>());
}

class StaticMockChatMsgModel {
  String appLang;
  String learnLang;
  String audioUrl;
  bool isAi;

  StaticMockChatMsgModel({
    required this.appLang,
    required this.learnLang,
    required this.audioUrl,
    required this.isAi,
  });
}
