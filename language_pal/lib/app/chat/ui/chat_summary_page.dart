import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/data/conversation_rating.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_pal/common/ui/score_circle.dart';

class ChatSummaryPage extends StatelessWidget {
  final ConversationRating rating;
  const ChatSummaryPage(this.rating, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.conversation_summary_title),
      ),
      body: Center(
        child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        painter: ScoreCircle(rating.totalScore, context),
                        size: const Size(100, 100),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${rating.totalScore}/10",
                            style: TextStyle(
                                fontSize: 24,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            AppLocalizations.of(context)!
                                .conversation_total_score,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                                "${AppLocalizations.of(context)!.conversation_total_messages}: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 16)),
                            Text(rating.totalMessages.toString(),
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                "${AppLocalizations.of(context)!.conversation_total_retries}: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 16)),
                            Text(rating.totalRetries.toString(),
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                "${AppLocalizations.of(context)!.conversation_goal_score}: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 16)),
                            Text(rating.goalScore.toString(),
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                "${AppLocalizations.of(context)!.conversation_ai_score}: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 16)),
                            Text(rating.aiScore.toString(),
                                style: const TextStyle(fontSize: 16)),
                          ],
                        )
                      ])
                ]),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!
                      .conversation_summary_suggestions,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.remove),
                    const SizedBox(width: 8),
                    Flexible(
                        child: Text(
                      rating.suggestion1,
                      softWrap: true,
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.remove),
                    const SizedBox(width: 8),
                    Flexible(
                        child: Text(
                      rating.suggestion2,
                      softWrap: true,
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.remove),
                    const SizedBox(width: 8),
                    Flexible(
                        child: Text(
                      rating.suggestion3,
                      softWrap: true,
                    )),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
