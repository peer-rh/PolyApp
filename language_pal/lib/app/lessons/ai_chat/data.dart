import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class ChatMsg {
  String msg;
  bool isAi;
  ChatMsg(this.msg, this.isAi);
  Map<String, String> toGpt();
  Map<String, dynamic> toJson();
  factory ChatMsg.fromJson(Map<String, dynamic> json) {
    return switch (json["isAi"] as bool) {
      true => AIChatMsg.fromJson(json),
      false => UserChatMsg.fromJson(json),
    };
  }
}

class AIChatMsg extends ChatMsg {
  AIChatMsg(msg) : super(msg, true);

  @override
  Map<String, String> toGpt() {
    return {"content": msg, "role": "assistant"};
  }

  @override
  Map<String, dynamic> toJson() {
    return {"text": msg, "isAi": isAi};
  }

  factory AIChatMsg.fromJson(Map<String, dynamic> json) {
    return AIChatMsg(json["text"] as String);
  }
}

class UserChatMsg extends ChatMsg {
  UserChatMsg(msg) : super(msg, false);
  UserMsgRating? rating;

  @override
  Map<String, String> toGpt() {
    return {"content": msg, "role": "user"};
  }

  @override
  Map<String, dynamic> toJson() {
    return {"text": msg, "isAi": isAi, "rating": rating?.toJson()};
  }

  factory UserChatMsg.fromJson(Map<String, dynamic> json) {
    return UserChatMsg(json["text"] as String);
  }
}

enum ChatStatus {
  initialising("initialising"),
  waitingForUser("waitingForUser"),
  waitingForUserRedo("waitingForUserRedo"),
  waitingForUserMsgRating("waitingForUserMsgRating"),
  waitingForAIResponse("waitingForAIResponse"),
  waitingForConvRating("waitingForConvRating"),
  finished("finished");

  const ChatStatus(this.name);
  final String name;

  factory ChatStatus.fromString(String name) {
    return ChatStatus.values.firstWhere((e) => e.name == name);
  }
}

class UserMsgRating {
  final MsgRatingType type;
  final String? suggestion;
  final String? suggestionTranslated;
  final String explanation;
  final String? meCorrected;
  final String? meCorrectedTranslated;

  UserMsgRating(this.type, this.suggestion, this.suggestionTranslated,
      this.meCorrected, this.meCorrectedTranslated, this.explanation);

  Map<String, dynamic> toJson() {
    return {
      "type": type.index,
      "suggestion": suggestion,
      "suggestion_translated": suggestionTranslated,
      "me_corrected": meCorrected,
      "me_corrected_translated": meCorrectedTranslated,
      "explanation": explanation,
    };
  }

  factory UserMsgRating.fromJson(Map<String, dynamic> data) {
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
      default:
        return MsgRatingType.notParse;
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
