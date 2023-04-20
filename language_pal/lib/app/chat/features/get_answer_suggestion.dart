import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_pal/app/chat/data/user_msg_rating_model.dart';
import 'package:language_pal/app/chat/logic/conversation_provider.dart';

class AnswerSuggestionButton extends StatelessWidget {
  final ConversationProvider conv;
  const AnswerSuggestionButton(this.conv, {super.key});

  showSuggestion(BuildContext context, UserMsgRating rating) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.chat_suggestion_title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(rating.meCorrected ??
                    "Error: No Corrected Version Available"),
                const Divider(),
                Text(
                    rating.meCorrectedTranslated ??
                        "Error: No translation available",
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.8))),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                      AppLocalizations.of(context)!.chat_suggestion_not_use)),
              if (rating.meCorrected != null)
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      conv.addPersonMsg(rating.meCorrected!, suggested: true);
                    },
                    child:
                        Text(AppLocalizations.of(context)!.chat_suggestion_use))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: () async {
        var lastMsg = conv.currentUserMsg!.msgs.last;
        if (context.mounted) {
          showSuggestion(context, lastMsg.rating!);
        }
      },
      style: IconButton.styleFrom(
        focusColor: colors.onSurfaceVariant.withOpacity(0.12),
        highlightColor: colors.onSurface.withOpacity(0.12),
        side: BorderSide(color: colors.outline),
      ),
      icon: const Icon(Icons.question_mark, size: 18),
    );
  }
}
