import 'package:cloud_functions/cloud_functions.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/common/languages.dart';

class Response {
  String message;
  bool endOfConversation;
  Response(this.message, this.endOfConversation);
}

Future<Response> getAIResponse(Conversation conv) async {
  final response = await FirebaseFunctions.instance
      .httpsCallable("getChatGPTResponse")
      .call({
    "language": LanguageModel.fromCode(conv.scenario.learnLang).englishName,
    "messages": conv.getLastMsgs(8),
    "scenario": conv.scenario.scenarioDesc
  });
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
  if (msg.toLowerCase().contains("[end]")) {
    end = true;
    msg = msg.substring(0, msg.toLowerCase().indexOf("[end]")).trim();
  }
  return ParserResult(msg.trim(), end);
}
