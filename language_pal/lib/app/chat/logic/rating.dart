import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_pal/app/chat/models/messages.dart';

class MsgRating {
  final MsgRatingType type;
  final String? suggestion;
  final String? suggestionTranslated;
  final String explanation;

  MsgRating(
      this.type, this.suggestion, this.suggestionTranslated, this.explanation);
}

Future<MsgRating> getRating(String scenarioShort, String assistantName,
    Messages msgs, String lang) async {
  final response =
      await FirebaseFunctions.instance.httpsCallable('getAnswerRating').call({
    "environment": scenarioShort,
    "assistant_name": assistantName,
    "messages": msgs.getLastMsgs(4).sublist(1), // Remove Scenario Msg
    "language": lang,
  });
  final data = response.data;
  String result = data["result"];
  MsgRatingType type = MsgRatingType.notParse;
  if (result.contains("grammar_error")) {
    type = MsgRatingType.grammarError;
  } else if (result.contains("incomplete")) {
    type = MsgRatingType.incomplete;
  } else if (result.contains("unclear")) {
    type = MsgRatingType.unclear;
  } else if (result.contains("impolite")) {
    type = MsgRatingType.impolite;
  } else if (result.contains("correct")) {
    type = MsgRatingType.correct;
  } else {
    FirebaseCrashlytics.instance.recordError(
        Exception("Invalid result type: ${data.toString()}"),
        StackTrace.current);
  }

  return MsgRating(type, data["suggestion"], data["suggestion_translated"],
      data["explanation"]!);
}

enum MsgRatingType {
  correct,
  grammarError,
  incomplete,
  unclear,
  impolite,
  notParse
}

String generateRatingShort(BuildContext context, MsgRatingType type) {
  switch (type) {
    case MsgRatingType.correct:
      return "${AppLocalizations.of(context)!.msg_rating_correct} 🤩";
    case MsgRatingType.grammarError:
      return "${AppLocalizations.of(context)!.msg_rating_grammar_error} 😐";
    case MsgRatingType.incomplete:
      return "${AppLocalizations.of(context)!.msg_rating_incomplete} 😢";
    case MsgRatingType.unclear:
      return "${AppLocalizations.of(context)!.msg_rating_unclear} 😕";
    case MsgRatingType.impolite:
      return "${AppLocalizations.of(context)!.msg_rating_impolite} 😖";
    case MsgRatingType.notParse:
      return "${AppLocalizations.of(context)!.msg_rating_not_parse} 🫤";
  }
}
