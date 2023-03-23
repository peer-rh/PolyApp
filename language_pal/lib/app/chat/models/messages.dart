import 'package:language_pal/app/chat/logic/rating.dart';

abstract class MsgModel {
  Map<String, String> toMap();
}

class AIMsgModel extends MsgModel {
  String msg;
  String? translations;
  String? audioPath;
  AIMsgModel(this.msg);

  @override
  Map<String, String> toMap() {
    return {
      'content': msg,
      'role': 'assistant',
    };
  }
}

class PersonMsgModel extends MsgModel {
  String msg;
  MsgRating? rating;
  PersonMsgModel(this.msg);

  @override
  Map<String, String> toMap() {
    return {
      'content': msg,
      'role': 'user',
    };
  }
}

class SystemMessage extends MsgModel {
  String msg;
  SystemMessage(this.msg);

  @override
  Map<String, String> toMap() {
    return {
      'content': msg,
      'role': 'system',
    };
  }
}

class Messages {
  SystemMessage systemMessage;
  List<MsgModel> msgs = [];

  Messages(this.systemMessage);

  void addMsg(dynamic msg) {
    msgs.add(msg);
  }

  List<Map<String, String>> getLastMsgs() {
    List<MsgModel> msgs = [systemMessage];
    if (this.msgs.length > 10) {
      msgs.addAll(this.msgs.sublist(this.msgs.length - 10));
    } else {
      msgs.addAll(this.msgs);
    }
    return msgs.map((e) => e.toMap()).toList();
  }
}
