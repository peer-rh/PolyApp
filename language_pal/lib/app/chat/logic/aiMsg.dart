import 'package:cloud_functions/cloud_functions.dart';

class Response {
  String message;
  String actualMessage; // Is needed to keep relevancyScore
  double relevancyScore;
  bool endOfConversation;
  Response(this.message, this.relevancyScore, this.actualMessage,
      this.endOfConversation);
}

Future<Response> getAIRespone(List<Map<String, String>> msgs) async {
  final response = await FirebaseFunctions.instance
      .httpsCallable("getChatGPTResponse")
      .call(msgs);
  String message = response.data;
  ParserResult result = parseAIMsg(message);
  return Response(result.message, result.relevancyScore, message, result.endOfConversation);
}

class ParserResult {
  double relevancyScore;
  String message;
  bool endOfConversation;
  ParserResult(this.relevancyScore, this.message, this.endOfConversation);
}

ParserResult parseAIMsg(String msg) {
  List<String> parts = msg.split("]");
  parts[0] = parts[0].replaceAll("[relevancy_score:", "").trim();
  double relevanceScore = double.parse(parts[0]);
  bool end = false;
  if (parts[1].contains("END_OF_CONVERSATION")) {
    end = true; 
    parts[1] = parts[1].replaceAll("END_OF_CONVERSATION", "").trim();
  }
  return ParserResult(relevanceScore, parts[1].trim(), end);
}
