import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:language_pal/app/chat/models/messages.dart';

class ConversationRating {
  final int? goalScore;
  final int? aiScore;
  final int totalMessages;
  final int totalRetries;
  final int totalScore;
  final String suggestion1;
  final String suggestion2;
  final String suggestion3;

  ConversationRating(
    this.goalScore,
    this.aiScore,
    this.totalMessages,
    this.totalRetries,
    this.totalScore,
    this.suggestion1,
    this.suggestion2,
    this.suggestion3,
  );

  Map<String, dynamic> toMap() {
    return {
      "goal_score": goalScore,
      "ai_score": aiScore,
      "total_messages": totalMessages,
      "total_retries": totalRetries,
      "total_score": totalScore,
      "suggestion_1": suggestion1,
      "suggestion_2": suggestion2,
      "suggestion_3": suggestion3,
    };
  }

  factory ConversationRating.fromMap(Map<String, dynamic> map) {
    return ConversationRating(
      map["goal_score"],
      map["ai_score"],
      map["total_messages"],
      map["total_retries"],
      map["total_score"],
      map["suggestion_1"],
      map["suggestion_2"],
      map["suggestion_3"],
    );
  }
}

Future<ConversationRating> getConversationRating(
    String lang, Conversation msgs) async {
  final response = await FirebaseFunctions.instance
      .httpsCallable('getConversationRating')
      .call({
    "environment": msgs.scenario.environmentDesc,
    "assistant_name": msgs.scenario.ratingAssistantName,
    "messages": msgs.msgs.map((e) => e.toMap()).toList(),
    "language": lang,
    "goal": msgs.scenario.goal,
  });
  int totalMessages = msgs.msgs.length;
  int totalRetries = 0;
  int goalScore = response.data["goal_score"];
  int aiScore = response.data["overall_score"];
  for (var msg in msgs.msgs) {
    if (msg is PersonMsgModel) {
      totalRetries += msg.msgs.length - 1;
    }
  }
  int totalScore = 3 * goalScore +
      2 * aiScore +
      max(0, ((1 - totalRetries / totalMessages) * 10).round());
  totalScore = (totalScore / 6).round();
  return ConversationRating(
    goalScore,
    aiScore,
    totalMessages,
    totalRetries,
    totalScore,
    response.data["suggestion_1"],
    response.data["suggestion_2"],
    response.data["suggestion_3"],
  );
}
