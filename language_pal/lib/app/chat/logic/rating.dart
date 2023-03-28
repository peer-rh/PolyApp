import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_pal/app/chat/models/messages.dart';

class MsgRating {
  final MsgRatingType type;
  final String details;

  MsgRating(this.type, this.details);
}

Future<MsgRating> getRating(String scenarioShort, String assistantName,
    Messages msgs, String lang, String great, String good, String poor) async {
  final response =
      await FirebaseFunctions.instance.httpsCallable('getAnswerRating').call({
    "environment": scenarioShort,
    "assistant_name": assistantName,
    "messages": (msgs.msgs.length >= 4)
        ? msgs.msgs.sublist(msgs.msgs.length - 4).map((e) => e.toMap()).toList()
        : msgs.msgs.map((e) => e.toMap()).toList(),
    "language": lang,
  });
  String data = response.data;
  MsgRatingType type = MsgRatingType.notParse;
  if (data.toLowerCase().contains(great.toLowerCase())) {
    type = MsgRatingType.great;
  } else if (data.toLowerCase().contains(good.toLowerCase())) {
    type = MsgRatingType.good;
  } else if (data.toLowerCase().contains(poor.toLowerCase())) {
    type = MsgRatingType.poor;
  }
  return MsgRating(type, data);
}

enum MsgRatingType { great, good, poor, notParse }

String generateRatingShort(BuildContext context, MsgRatingType type) {
  switch (type) {
    case MsgRatingType.great:
      return "${AppLocalizations.of(context)!.msg_rating_great} 🤩";
    case MsgRatingType.good:
      return "${AppLocalizations.of(context)!.msg_rating_good} 😃";
    case MsgRatingType.poor:
      return "${AppLocalizations.of(context)!.msg_rating_poor} 😢";
    case MsgRatingType.notParse:
      return "${AppLocalizations.of(context)!.msg_rating_not_parse} 🫤";
  }
}
