import 'package:cloud_functions/cloud_functions.dart';
import 'package:language_pal/app/chat/models/messages.dart';

class Response {
  String message;
  bool endOfConversation;
  Response(this.message, this.endOfConversation);
}

Future<Response> getAIResponse(Conversation conv, String learnLang) async {
  final response = await FirebaseFunctions.instance
      .httpsCallable("getChatGPTResponse")
      .call(
          {
                "language": learnLang,
                "messages": conv.getLastMsgs(8),
                "scenario": conv.scenario.scenarioDesc
          }
      );
  String message = response.data;
  ParserResult result = parseAIMsg(message);
  return Response(result.message, result.endOfConversation);
}

class ParserResult {
  String message;
  bool endOfConversation;
  ParserResult(this.message, this.endOfConversation);
}

ParserResult parseAIMsg(String msg) {
  bool end = false;
  if (msg.toLowerCase().contains("end_of_conversation")) {
    end = true;
    msg = msg
        .substring(0, msg.toLowerCase().indexOf("end_of_conversation"))
        .trim();
  }
  return ParserResult(msg.trim(), end);
}
