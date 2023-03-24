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
  if (msg.toLowerCase().contains("end_of_conversation")) {
    end = true;
    msg = msg.replaceAll("END_OF_CONVERSATION", "");
    msg = msg.replaceAll("End_Of_Conversation", "");
    msg = msg.replaceAll("end_of_conversation", "").trim();
  }
  return ParserResult(msg.trim(), end);
}
