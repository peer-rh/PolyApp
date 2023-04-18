import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/common/languages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<String> getTranslations(String msg, String lang) async {
  // Call cloud function to get translations
  final response = await FirebaseFunctions.instance
      .httpsCallable('getTranslation')
      .call({"text": msg, "lang": LanguageModel.fromCode(lang).englishName});
  return response.data;
}

class TranslationButton extends StatefulWidget {
  final AIMsgModel msg;
  const TranslationButton(this.msg, {super.key});

  @override
  State<TranslationButton> createState() => _TranslationButtonState();
}

class _TranslationButtonState extends State<TranslationButton> {
  bool loading = false;

  showTranslation(BuildContext context, String translation) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.msg_translation_title),
            content: Text(translation),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.close))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: loading
          ? null
          : () async {
              if (widget.msg.translations != null) {
                showTranslation(context, widget.msg.translations!);
                return;
              }
              String lang = Localizations.localeOf(context).languageCode;
              setState(() {
                loading = true;
              });
              widget.msg.translations =
                  await getTranslations(widget.msg.msg, lang);
              setState(() {
                loading = false;
              });
              if (context.mounted) {
                showTranslation(context, widget.msg.translations!);
              }
            },
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(),
            )
          : const Icon(Icons.translate, size: 18),
    );
  }
}
