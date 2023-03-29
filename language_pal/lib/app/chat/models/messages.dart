import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:language_pal/app/chat/logic/rating.dart';
import 'package:language_pal/app/chat/logic/total_rating.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';

abstract class MsgModel {
  Map<String, String> toMap();
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

  List<Map<String, String>> getLastMsgs() {
    List<MsgModel> msgs = [systemMessage];
    if (this.msgs.length > 10) {
      msgs.addAll(this.msgs.sublist(this.msgs.length - 10));
    } else {
      msgs.addAll(this.msgs);
    }
    return msgs.map((e) => e.toMap()).toList();
  }

  Map<String, dynamic> toFirestore() {
    // TODO: Remember each rating of each message
    List<MsgModel> msgs = [systemMessage];
    msgs.addAll(this.msgs);
    return {
      "rating": rating!.toMap(),
      "messages": msgs.map((e) => e.toMap()).toList(),
      "scenario": scenario.uniqueId,
    };
  }

  factory Messages.fromFirestore(
      Map<String, dynamic> data, ScenarioModel scenario) {
    List<dynamic> msgs = data['messages'];
    List<MsgModel> msgModels = msgs.map((e) {
      if (e['role'] == 'assistant') {
        return AIMsgModel(e['content']);
      } else if (e['role'] == 'user') {
        return PersonMsgModel(e['content']);
      } else {
        return SystemMessage(e['content']);
      }
    }).toList();
    return Messages(scenario)
      ..msgs = msgModels
      ..rating = ConversationRating.fromMap(data['rating']);
  }
}
