import 'package:cloud_functions/cloud_functions.dart';
import 'package:poly_app/app/chat/data/messages.dart';
import 'package:poly_app/app/chat/logic/conversation_provider.dart';
import 'package:poly_app/app/chat/logic/get_conversation_rating.dart';

class Response {
  String message;
  bool endOfConversation;
  Response(this.message, this.endOfConversation);
}

extension GetAIResponse on ConversationProvider {
  void getAIResponse() async {
    currentUserMsg = null;
    status = ConversationStatus.waitingForAIResponse;
    final response = await FirebaseFunctions.instance
        .httpsCallable("getChatGPTResponse")
        .call({
      "language": learnLang.englishName,
      "messages": conv.getLastMsgs(8),
      "scenario": scenario.scenarioDesc
    });

    String msg = response.data;
    if (msg.toLowerCase().contains("[end]")) {
      msg = msg.substring(0, msg.toLowerCase().indexOf("[end]")).trim();
      conv.addMsg(AIMsgModel(msg));
      getConversationRating();
    } else {
      conv.addMsg(AIMsgModel(msg));
      status = ConversationStatus.waitingForUser;
    }
  }
}
