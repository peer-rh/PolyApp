import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/logic/total_rating.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatSummaryPage extends StatelessWidget {
  ConversationRating rating;
  ChatSummaryPage(this.rating, {super.key});

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
              children: [
                Row(children: [
                  ScoreCircle(rating.score ?? 0),
                  const SizedBox(width: 16),
                  const Text("Great job!")
                ]),
                const SizedBox(height: 16),
                Text(rating.details),
              ],
            )),
      ),
    );
  }
}

class ScoreCircle extends StatelessWidget {
  final int score;
  const ScoreCircle(this.score, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(
            value: score / 100,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 16,
          ),
        ),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
