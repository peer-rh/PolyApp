import 'package:flutter/material.dart';
import 'package:poly_app/app/chat/data/conversation_rating.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poly_app/common/ui/score_circle.dart';

class ChatSummaryPage extends StatelessWidget {
  final ConversationRating rating;
  const ChatSummaryPage(this.rating, {super.key});

  void showScoreExplanationDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
                mainAxisSize: MainAxisSize.min,
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
                ]),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.close),
              )
            ],
          );
        });
  }

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        painter: ScoreCircle(rating.totalScore, context,
                            strokeWidth: 16),
                        size: Size(MediaQuery.of(context).size.width - 128,
                            MediaQuery.of(context).size.width - 128),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${rating.totalScore}/10",
                            style: TextStyle(
                                fontSize: 64,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            AppLocalizations.of(context)!
                                .conversation_total_score,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: const Icon(Icons.help_rounded),
                            onPressed: () {
                              showScoreExplanationDialog(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
