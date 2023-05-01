class LearnTrackModel {
  final String title;
  final List<ChapterModel> chapters;

  LearnTrackModel({
    required this.title,
    required this.chapters,
  });

  factory LearnTrackModel.fromMap(Map<String, dynamic> map) {
    return LearnTrackModel(
      title: map["title"],
      chapters: (map["items"] as List<dynamic>)
          .map((e) => ChapterModel.fromMap(e))
          .toList(),
    );
  }
}

class ChapterModel {
  final String id;
  final String title;
  final List<LessonModel> lessons;

  ChapterModel({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory ChapterModel.fromMap(Map<String, dynamic> contentMap) {
    return ChapterModel(
      id: contentMap["id"],
      title: contentMap["title"],
      lessons: (contentMap["items"] as List<dynamic>)
          .map((e) => LessonModel.fromMap(e))
          .toList(),
    );
  }
}

class LessonModel {
  final String id;
  final String title;
  final List<AbstractPart> content;

  LessonModel({
    required this.id,
    required this.title,
    required this.content,
  });

  factory LessonModel.fromMap(Map<String, dynamic> contentMap) {
    return LessonModel(
      id: contentMap["id"],
      title: contentMap["title"],
      content: (contentMap["items"] as List<dynamic>)
          .map((e) => AbstractPart.fromMap(e))
          .toList(),
    );
  }
}

abstract class AbstractPart {
  final String title;
  final String id;

  AbstractPart({
    required this.title,
    required this.id,
  });

  factory AbstractPart.fromMap(Map<String, dynamic> map) {
    switch (map["type"]) {
      case "vocab":
        return VocabPart.fromMap(map);
      case "mock_chat":
        return MockChatPart.fromMap(map);
      case "ai_chat":
        return ChatPart.fromMap(map);
      default:
        throw Exception("Unknown part type");
    }
  }
}

class VocabPart extends AbstractPart {
  final List<VocabModel> vocab;

  VocabPart({
    required title,
    required id,
    required this.vocab,
  }) : super(title: title, id: id);

  factory VocabPart.fromMap(Map<String, dynamic> map) {
    return VocabPart(
      id: map["id"],
      title: map["title"],
      vocab: (map["items"] as List<dynamic>)
          .map((e) => VocabModel(
                id: e["id"],
                learnLang: e["learn_lang"],
                appLang: e["app_lang"],
                audioUrl: e["audio_url"],
              ))
          .toList(),
    );
  }
}

class VocabModel {
  final bool id;
  final String learnLang;
  final String appLang;
  final String audioUrl;

  VocabModel({
    required this.id,
    required this.learnLang,
    required this.appLang,
    required this.audioUrl,
  });
}

class MockChatPart extends AbstractPart {
  final List<MockMsg> chats;
  final String avatar;

  MockChatPart({
    required title,
    required id,
    required this.chats,
    required this.avatar,
  }) : super(title: title, id: id);

  factory MockChatPart.fromMap(Map<String, dynamic> map) {
    return MockChatPart(
      title: map["title"],
      id: map["id"],
      avatar: map["avatar"],
      chats: (map["items"] as List<dynamic>)
          .map((e) => MockMsg(
                id: e["id"],
                isAi: e["type"] == "ai",
                appLang: e["app_lang"],
                learnLang: e["learn_lang"],
                audioUrl: e["audio_url"],
              ))
          .toList(),
    );
  }
}

class MockMsg {
  final bool id;
  final bool isAi;
  final String appLang;
  final String learnLang;
  final String audioUrl;

  MockMsg({
    required this.id,
    required this.isAi,
    required this.appLang,
    required this.learnLang,
    required this.audioUrl,
  });
}

class ChatPart extends AbstractPart {
  final String avatar;
  final Map<String, String> voiceSettings;
  final String startingMsg;
  final String promptDesc;
  final String goalDesc;

  ChatPart({
    required title,
    required id,
    required this.avatar,
    required this.voiceSettings,
    required this.startingMsg,
    required this.promptDesc,
    required this.goalDesc,
  }) : super(title: title, id: id);

  factory ChatPart.fromMap(Map<String, dynamic> map) {
    return ChatPart(
      title: map["title"],
      id: map["id"],
      avatar: map["avatar"],
      voiceSettings: map["voice_settings"].cast<String, String>(),
      startingMsg: map["starting_msg"],
      promptDesc: map["prompt_desc"],
      goalDesc: map["goal_desc"],
    );
  }
}

enum PartStatus {
  done("done"),
  locked("locked"),
  inProgress("in_progress"),
  skipped("skipped");

  const PartStatus(this.code);
  final String code;

  factory PartStatus.fromCode(String status) {
    switch (status) {
      case "done":
        return PartStatus.done;
      case "locked":
        return PartStatus.locked;
      case "skipped":
        return PartStatus.skipped;
      case "in_progress":
        return PartStatus.inProgress;
      default:
        throw Exception("Unknown part status");
    }
  }
}
