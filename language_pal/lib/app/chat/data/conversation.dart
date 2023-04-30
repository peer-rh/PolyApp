import 'package:poly_app/app/chat/data/conversation_rating.dart';
import 'package:poly_app/app/chat/data/messages.dart';

class Conversation {
  String scenarioId;
  String langaugeCode;

  List<MsgModel> _msgs = [];
  ConversationRating? rating;

  Conversation(this.scenarioId, this.langaugeCode);

  int get length => _msgs.length;
  List<MsgModel> get msgs => _msgs;

  void addMsg(MsgModel msg) {
    _msgs.add(msg);
  }

  List<Map<String, String>> getLastMsgs(int n) {
    List<MsgModel> out = [];
    if (_msgs.length > n) {
      out = _msgs.sublist(_msgs.length - n);
    } else {
      out = _msgs;
    }
    return out.map((e) => e.toGPT()).toList();
  }

  Map<String, dynamic> toFirestore() {
    return {
      "rating": rating?.toMap(),
      "messages": _msgs.map((e) => e.toFirestore()).toList(),
      "scenario": scenarioId,
      "language": langaugeCode,
    };
  }

  factory Conversation.fromFirestore(Map<String, dynamic> data) {
    List<dynamic> msgsData = data['messages'];
    List<MsgModel> msgModels = msgsData.map((e) {
      if (e['type'] == 'ai') {
        return AIMsgModel.fromFirestore(e);
      } else if (e['type'] == 'person') {
        return PersonMsgListModel.fromFirestore(e);
      } else {
        throw Exception("Unknown message type: ${e['type']}");
      }
    }).toList();
    return Conversation(data["scenario"], data["language"])
      .._msgs = msgModels
      ..rating = data["rating"] != null
          ? ConversationRating.fromMap(data['rating'])
          : null;
  }
}
