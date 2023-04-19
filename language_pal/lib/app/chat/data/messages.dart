import 'package:language_pal/app/chat/logic/rating.dart';

abstract class MsgModel {
  Map<String, String> toGPT();
  Map<String, dynamic> toFirestore();
}

class AIMsgModel extends MsgModel {
  bool loaded = true;
  String msg;
  String? translations;
  String? audioPath;
  AIMsgModel(this.msg);

  @override
  Map<String, String> toGPT() {
    return {
      'content': msg,
      'role': 'assistant',
    };
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'content': msg,
      'type': 'ai',
    };
  }

  factory AIMsgModel.fromFirestore(Map<String, dynamic> data) {
    return AIMsgModel(data['content']);
  }
}

class SingularPersonMsgModel {
  String msg;
  bool suggested = false;
  MsgRating? rating;
  SingularPersonMsgModel(this.msg);
}

class PersonMsgModel extends MsgModel {
  late List<SingularPersonMsgModel> msgs;
  PersonMsgModel(this.msgs);

  @override
  Map<String, String> toGPT() {
    return {
      'content': msgs.last.msg,
      'role': 'user',
    };
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'content': msgs
          .map((e) => {
                "content": e.msg,
                "rating": e.rating?.toMap(),
                "suggested": e.suggested
              })
          .toList(),
      'type': 'person',
    };
  }

  factory PersonMsgModel.fromFirestore(Map<String, dynamic> data) {
    List<dynamic> msgs = data['content'];
    PersonMsgModel model = PersonMsgModel([]);
    model.msgs = msgs.map((e) {
      return SingularPersonMsgModel(e['content'])
        ..rating =
            e["rating"] == null ? null : MsgRating.fromFirestore(e["rating"])
        ..suggested = e["suggested"] ?? false;
    }).toList();
    return model;
  }
}

class SystemMessage extends MsgModel {
  String msg;
  SystemMessage(this.msg);

  @override
  Map<String, String> toGPT() {
    return {
      'content': msg,
      'role': 'system',
    };
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'content': msg,
      'type': 'system',
    };
  }
}
