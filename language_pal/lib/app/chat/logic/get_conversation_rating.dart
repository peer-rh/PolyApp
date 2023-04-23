import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:language_pal/app/chat/data/conversation_rating.dart';
import 'package:language_pal/app/chat/data/messages.dart';
import 'package:language_pal/app/chat/logic/conversation_provider.dart';
import 'package:language_pal/app/chat/logic/store_conv.dart';

extension GetConversationRating on ConversationProvider {
  void getConversationRating() async {
    status = ConversationStatus.waitingForConvRating;
    final response = await FirebaseFunctions.instance
        .httpsCallable('getConversationRating')
        .call({
      "environment": scenario.environmentDesc,
      "assistant_name": scenario.ratingAssistantName,
      "messages": conv.getLastMsgs(conv.length),
      "language": appLang.englishName,
      "goal": scenario.goal,
    });
    int totalMessages = conv.length;
    int totalRetries = 0;
    int goalScore = response.data["goal_score"];
    int aiScore = response.data["overall_score"];
    for (var msg in conv.msgs) {
      if (msg is PersonMsgListModel) {
        totalRetries += msg.nRetries;
      }
    }
    int totalScore = 3 * goalScore +
        2 * aiScore +
        max(0, ((1 - totalRetries / totalMessages) * 10).round());
    totalScore = (totalScore / 6).round();
    conv.rating = ConversationRating(
      goalScore: goalScore,
      aiScore: aiScore,
      totalMessages: totalMessages,
      totalRetries: totalRetries,
      totalScore: totalScore,
      suggestion1: response.data["suggestion_1"],
      suggestion2: response.data["suggestion_2"],
      suggestion3: response.data["suggestion_3"],
    );

    status = ConversationStatus.finished;
    deleteConv();

    bestScore.updateBestScore(scenario.uniqueId, conv.rating!.totalScore);
    pastConvs.addConversation(conv);
  }
}
