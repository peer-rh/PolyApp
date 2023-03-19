import 'package:cloud_functions/cloud_functions.dart';

class Response {
  String message;
  String actualMessage; // Is needed to keep relevancyScore
  double relevancyScore;
  Response(this.message, this.relevancyScore, this.actualMessage);
}

Future<Response> getAIRespone(List<Map<String, String>> msgs) async {
  final response = await FirebaseFunctions.instance
      .httpsCallable("getChatGPTResponse")
      .call(msgs);
  String message = response.data;
  ParserResult result = parseAIMsg(message);
  return Response(result.message, result.relevancyScore, message);
}

class ParserResult {
  double relevancyScore;
  String message;
  ParserResult(this.relevancyScore, this.message);
}

ParserResult parseAIMsg(String msg) {
  List<String> parts = msg.split("]");
  parts[0] = parts[0].replaceAll("[relevancy_score:", "").trim();
  double relevanceScore = double.parse(parts[0]);
  return ParserResult(relevanceScore, parts[1].trim());
}
