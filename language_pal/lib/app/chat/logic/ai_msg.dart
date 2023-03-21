import 'package:cloud_functions/cloud_functions.dart';

class Response {
  String message;
  bool endOfConversation;
  Response(this.message, this.endOfConversation);
}

Future<Response> getAIRespone(List<Map<String, String>> msgs) async {
  final response = await FirebaseFunctions.instance
      .httpsCallable("getChatGPTResponse")
      .call(msgs);
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
  if (msg.contains("END_OF_CONVERSATION")) {
    end = true;
    msg = msg.replaceAll("END_OF_CONVERSATION", "").trim();
  }
  return ParserResult(msg.trim(), end);
}
