import 'package:poly_app/app/lessons/common/input/data.dart';

class MockChatMsg {
  bool isAi;
  String learnLang;
  String appLang;
  InputStep? step;

  MockChatMsg(this.learnLang, this.appLang, this.isAi, {this.step});

  factory MockChatMsg.fromJson(Map<String, dynamic> json) {
    return MockChatMsg(json['learnLang'], json['appLang'], json['isAi'],
        step: json['inputStep'] != null
            ? InputStep.fromJson(json['inputStep'])
            : null);
  }

  Map<String, dynamic> toJson() {
    return {
      "learnLang": learnLang,
      "appLang": appLang,
      "isAi": isAi,
      "inputStep": step?.toJson(),
    };
  }
}

class StaticMockChatLessonModel {
  String id;
  String name;
  String avatar;
  List<StaticMockChatMsgModel> msgList;

  StaticMockChatLessonModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.msgList,
  });

  factory StaticMockChatLessonModel.fromJson(
          Map<String, dynamic> json, String id) =>
      StaticMockChatLessonModel(
          id: id,
          name: json["name"],
          avatar: json["content"]["avatar"],
          msgList: json["content"]["msg_list"]
              .map((x) => StaticMockChatMsgModel(
                    appLang: x["app_lang"],
                    learnLang: x["learn_lang"],
                    isAi: x["is_ai"],
                  ))
              .toList()
              .cast<StaticMockChatMsgModel>());
}

class StaticMockChatMsgModel {
  String appLang;
  String learnLang;
  bool isAi;

  StaticMockChatMsgModel({
    required this.appLang,
    required this.learnLang,
    required this.isAi,
  });
}
