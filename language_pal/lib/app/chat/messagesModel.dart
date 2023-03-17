import 'package:cloud_functions/cloud_functions.dart';

class Message {
  String role;
  String msg;
  Message({required this.role, required this.msg});
}

class MessageList {
  List<Message> msgs = [];
  void addMsg(Message msg) {
    msgs.add(msg);
  }

  List<Map<String, String>> toJson() {
    // TODO: Make only 0 and last 10 messages
    return msgs
        .map(
          (e) => {"role": e.role, "content": e.msg},
        )
        .toList();
  }

  Future fetchAnswer() async {
    // TODO: Seperate from Model Logic
    final response = await FirebaseFunctions.instance
        .httpsCallable("getChatGPTResponse")
        .call(toJson());
    addMsg(Message(role: "assistant", msg: response.data));
    return;
  }
}
