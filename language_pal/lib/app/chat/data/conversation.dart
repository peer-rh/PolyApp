import 'package:language_pal/app/chat/data/messages.dart';
import 'package:language_pal/app/chat/logic/total_rating.dart';

enum ConversationState {
  empty,
  inProgress,
  finished,
}

class Conversation {
  late SystemMessage systemMessage;
  late String scenarioId;
  List<MsgModel> _msgs = [];
  ConversationRating? rating;

  Conversation(this.systemMessage);

  void addMsg(dynamic msg) {
    _msgs.add(msg);
  }

  List<Map<String, String>> getLastMsgs(int n) {
    List<MsgModel> msgs = [systemMessage];
    if (this._msgs.length > n) {
      msgs.addAll(this._msgs.sublist(this._msgs.length - n));
    } else {
      msgs.addAll(this._msgs);
    }
    return msgs.map((e) => e.toGPT()).toList();
  }

  Map<String, dynamic> toFirestore() {
    return {
      "rating": rating?.toMap(),
      "systemMessage": systemMessage.msg,
      "messages": _msgs.map((e) => e.toFirestore()).toList(),
      "scenario": scenarioId,
    };
  }

  factory Conversation.fromFirestore(
      Map<String, dynamic> data) {
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
