import 'package:poly_app/app/chat/data/user_msg_rating_model.dart';

abstract class MsgModel {
  Map<String, String> toGPT();
  Map<String, dynamic> toFirestore();
}

class AIMsgModel extends MsgModel {
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
  bool suggested;
  UserMsgRating? rating;
  SingularPersonMsgModel(this.msg, {this.suggested = false, this.rating});
}

class PersonMsgListModel extends MsgModel {
  late List<SingularPersonMsgModel> msgs;
  PersonMsgListModel(this.msgs);

  int get nRetries => msgs.length - 1;

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

  factory PersonMsgListModel.fromFirestore(Map<String, dynamic> data) {
    List<dynamic> msgs = data['content'];
    PersonMsgListModel model = PersonMsgListModel([]);
    model.msgs = msgs.map((e) {
      return SingularPersonMsgModel(e['content'],
          rating: e["rating"] == null
              ? null
              : UserMsgRating.fromFirestore(e["rating"]),
          suggested: e['suggested'] ?? false);
    }).toList();
    return model;
  }
}
