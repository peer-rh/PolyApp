import 'package:cloud_functions/cloud_functions.dart';

class MsgRating {
  final String short;
  final String details;

  MsgRating(this.short, this.details);
}

Future<MsgRating> getRating(String scenarioShort, String assistantName,
    String assistantMsg, String userMsg) async {
  final response =
      await FirebaseFunctions.instance.httpsCallable('getAnswerRating').call({
    "scenario": scenarioShort,
    "assistant": assistantMsg,
    "assistant_name": assistantName,
    "user": userMsg
  });
  String data = response.data;
  String short = "";
  if (data.toLowerCase().contains("great answer")) {
    short = "Great Answer! 🤩";
  } else if (data.toLowerCase().contains("good answer")) {
    short = "Good Answer! 😃";
  } else if (data.toLowerCase().contains("poor answer")) {
    short = "Poor Answer 😢";
  } else {
    short = "Couldn't parse 🫤";
  }
  return MsgRating(short, data);
}
