import 'package:cloud_functions/cloud_functions.dart';
import 'package:language_pal/app/chat/models/messages.dart';

class ConversationRating {
  final int? score;
  final String details;

  ConversationRating(this.score, this.details);

  Map<String, dynamic> toMap() {
    return {
      "rating": score,
      "details": details,
    };
  }

  factory ConversationRating.fromMap(Map<String, dynamic> map) {
    return ConversationRating(
      map["rating"],
      map["details"],
    );
  }
}

Future<ConversationRating> getConversationRating(String scenarioShort,
    String assistantName, String lang, Conversation msgs) async {
  final response = await FirebaseFunctions.instance
      .httpsCallable('getConversationRating')
      .call({
    "environment": scenarioShort,
    "assistant_name": assistantName,
    "messages": msgs.msgs.map((e) => e.toMap()).toList(),
    "language": lang,
  });
  String data = response.data;
  int? rating;
  if (lang == "en") {
    int startPos = data.indexOf("Rating: ") + 8;
    String a = data.substring(startPos, data.length - 1);
    rating = int.tryParse(a.substring(0, a.indexOf("/")));
    data = data.substring(0, startPos - 8);
  } else if (lang == "de") {
    int startPos = data.indexOf("Bewertung: ") + 11;
    String a = data.substring(startPos, data.length - 1);
    rating = int.tryParse(a.substring(0, a.indexOf("/")));
    data = data.substring(0, startPos - 11);
  }

  return ConversationRating(rating, data);
}
