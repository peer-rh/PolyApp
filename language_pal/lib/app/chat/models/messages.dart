import 'package:language_pal/app/chat/logic/rating.dart';
import 'package:language_pal/app/chat/logic/total_rating.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';

abstract class MsgModel {
  Map<String, String> toMap();
  Map<String, dynamic> toFirestore();
}

class AIMsgModel extends MsgModel {
  bool loaded = true;
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
  MsgRating? rating;
  SingularPersonMsgModel(this.msg);
}

class PersonMsgModel extends MsgModel {
  late List<SingularPersonMsgModel> msgs;
  PersonMsgModel(this.msgs);

  @override
  Map<String, String> toMap() {
    return {
      'content': msgs.last.msg,
      'role': 'user',
    };
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'content':
          msgs.map((e) => {"content": e.msg, "rating": e.rating}).toList(),
      'type': 'person',
    };
  }

  factory PersonMsgModel.fromFirestore(Map<String, dynamic> data) {
    List<dynamic> msgs = data['content'];
    PersonMsgModel model = PersonMsgModel(msgs.first['content']);
    model.msgs = msgs.map((e) {
      return SingularPersonMsgModel(e['content'])..rating = e['rating'];
    }).toList();
    return model;
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

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'content': msg,
      'type': 'system',
    };
  }
}

class Messages {
  ScenarioModel scenario;
  late SystemMessage systemMessage;
  List<MsgModel> msgs = [];
  ConversationRating? rating;

  Messages(this.scenario) {
    systemMessage = SystemMessage(scenario.prompt);
  }

  void addMsg(dynamic msg) {
    msgs.add(msg);
  }

  List<Map<String, String>> getLastMsgs(int n) {
    List<MsgModel> msgs = [systemMessage];
    if (this.msgs.length > n) {
      msgs.addAll(this.msgs.sublist(this.msgs.length - n));
    } else {
      msgs.addAll(this.msgs);
    }
    return msgs.map((e) => e.toMap()).toList();
  }

  Map<String, dynamic> toFirestore() {
    List<MsgModel> msgs = [systemMessage];
    msgs.addAll(this.msgs);
    return {
      "rating": rating!.toMap(),
      "messages": msgs.map((e) => e.toFirestore()).toList(),
      "scenario": scenario.uniqueId,
    };
  }

  factory Messages.fromFirestore(
      Map<String, dynamic> data, ScenarioModel scenario) {
    List<dynamic> msgs = data['messages'];
    List<MsgModel> msgModels = msgs.map((e) {
      if (e['type'] == 'ai') {
        return AIMsgModel.fromFirestore(e);
      } else if (e['type'] == 'user') {
        return PersonMsgModel.fromFirestore(e);
      } else {
        return SystemMessage(e['content']);
      }
    }).toList();
    return Messages(scenario)
      ..msgs = msgModels
      ..rating = ConversationRating.fromMap(data['rating']);
  }
}
