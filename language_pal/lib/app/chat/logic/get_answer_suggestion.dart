import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/logic/rating.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/common/languages.dart';
import 'package:provider/provider.dart';

class AnswerSuggestionButton extends StatelessWidget {
  Conversation conv;
  void Function(String, bool) sendMsg;
  AnswerSuggestionButton(this.conv, this.sendMsg, {super.key});

  showSuggestion(BuildContext context, MsgRating rating) {
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
                      sendMsg(rating.meCorrected!, false);
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
        String lang = context.read<AuthProvider>().user!.appLang;
        lang = convertLangCode(lang).getEnglishName();
        var lastMsg = conv.msgs.last as PersonMsgModel;
        if (context.mounted) {
          showSuggestion(context, lastMsg.msgs.last.rating!);
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
