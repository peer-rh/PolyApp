class LessonMetadataModel {
  String id;
  String title;
  String type;

  LessonMetadataModel({
    required this.id,
    required this.title,
    required this.type,
  });
}

class AiChatLessonModel {
  String id;
  String title;
  String avatar;
  String startingMsg;
  String promptDesc;
  String goalDesc;
  Map<String, dynamic> voiceSettings;

  AiChatLessonModel({
    required this.id,
    required this.title,
    required this.avatar,
    required this.startingMsg,
    required this.promptDesc,
    required this.goalDesc,
    required this.voiceSettings,
  });

  factory AiChatLessonModel.fromJson(Map<String, dynamic> map, String id) {
    return AiChatLessonModel(
      id: id,
      title: map["title"],
      avatar: map["content"]["avatar"],
      startingMsg: map["content"]["starting_msg"],
      promptDesc: map["content"]["prompt_desc"],
      goalDesc: map["content"]["goal_desc"],
      voiceSettings: map["content"]["voice_settings"].cast<String, dynamic>(),
    );
  }
}
