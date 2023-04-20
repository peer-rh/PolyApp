import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserMsgRating {
  final MsgRatingType type;
  final String? suggestion;
  final String? suggestionTranslated;
  final String explanation;
  final String? meCorrected;
  final String? meCorrectedTranslated;

  UserMsgRating(this.type, this.suggestion, this.suggestionTranslated,
      this.meCorrected, this.meCorrectedTranslated, this.explanation);

  Map<String, dynamic> toMap() {
    return {
      "type": type.index,
      "suggestion": suggestion,
      "suggestion_translated": suggestionTranslated,
      "me_corrected": meCorrected,
      "me_corrected_translated": meCorrectedTranslated,
      "explanation": explanation,
    };
  }

  factory UserMsgRating.fromFirestore(Map<String, dynamic> data) {
    return UserMsgRating(
      MsgRatingType.values[data["type"]],
      data["suggestion"],
      data["suggestion_translated"],
      data["me_corrected"],
      data["me_corrected_translated"],
      data["explanation"],
    );
  }
}

enum MsgRatingType {
  correct,
  grammarError,
  incomplete,
  unclear,
  impolite,
  notParse;

  factory MsgRatingType.fromString(String type) {
    switch (type) {
      case "correct":
        return MsgRatingType.correct;
      case "grammar_error":
        return MsgRatingType.grammarError;
      case "incomplete":
        return MsgRatingType.incomplete;
      case "unclear":
        return MsgRatingType.unclear;
      case "impolite":
        return MsgRatingType.impolite;
      case "not_parse":
        return MsgRatingType.notParse;
      default:
        throw Exception("Invalid rating type: $type");
    }
  }
}

extension MsgRatingTypeExt on MsgRatingType {
  String getTitle(BuildContext context) {
    switch (this) {
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
}
