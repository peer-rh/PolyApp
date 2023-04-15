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
      'content': msgs
          .map((e) => {"content": e.msg, "rating": e.rating?.toMap()})
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
            e["rating"] == null ? null : MsgRating.fromFirestore(e["rating"]);
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

enum ConversationState {
  finished,
  waitingForRating,
  waitingForAIMsg,
  waitingForUserMsg,
  waitingForUserRedo,
  waitingForFinalRating,
}

class Conversation {
  ConversationState state = ConversationState.waitingForUserMsg;
  ScenarioModel scenario;
  late SystemMessage systemMessage;
  List<MsgModel> msgs = [];
  ConversationRating? rating;

  Conversation(this.scenario) {
    systemMessage = SystemMessage(scenario.scenarioDesc);
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
    return {
      "state": state.index,
      "rating": rating?.toMap(),
      "systemMessage": systemMessage.msg,
      "messages": msgs.map((e) => e.toFirestore()).toList(),
      "scenario": scenario.uniqueId,
    };
  }

  factory Conversation.fromFirestore(
      Map<String, dynamic> data, ScenarioModel scenario) {
    List<dynamic> msgsData = data['messages'];
    List<MsgModel> msgModels = msgsData.map((e) {
      if (e['type'] == 'ai') {
        return AIMsgModel.fromFirestore(e);
      } else if (e['type'] == 'person') {
        return PersonMsgModel.fromFirestore(e);
      } else {
        throw Exception("Unknown message type: ${e['type']}");
      }
    }).toList();
    return Conversation(scenario)
      ..systemMessage = SystemMessage(data['systemMessage'])
      ..state = ConversationState.values[data['state']]
      ..msgs = msgModels
      ..rating = data["rating"] != null
          ? ConversationRating.fromMap(data['rating'])
          : null;
  }
}
