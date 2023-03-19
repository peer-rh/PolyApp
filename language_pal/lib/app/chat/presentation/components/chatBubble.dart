import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/logic/translation.dart';
import 'package:language_pal/app/chat/models/messages.dart';

class OwnMsgBubble extends StatelessWidget {
  final PersonMsgModel msg;
  const OwnMsgBubble(this.msg, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.all(5),
      child: Container(
        margin: const EdgeInsets.only(left: 80),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.blue),
        child: Column(
          children: [
            if (msg.relevancyScore != null)
              Text(
                "Relevancy Score: ${msg.relevancyScore}",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            Text(
              msg.msg,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            if (msg.grammarCorrection != null)
              TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Grammar Correction"),
                          content: Text(msg.grammarCorrection!),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Close"))
                          ],
                        );
                      });
                },
                child: const Text("Grammar Correction"),
              ),
          ],
        ),
      ),
    );
  }
}

class AiMsgBubble extends StatelessWidget {
  final AIMsgModel msg;
  String lang;
  AiMsgBubble(this.msg, this.lang, {super.key});

  showTranslation(BuildContext context, String translation) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Translation"),
            content: Text(translation),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.all(5),
      child: Container(
        margin: const EdgeInsets.only(right: 80),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.grey[500]),
        child: Column(
          children: [
            Text(
              msg.msg,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            TextButton(
                onPressed: () {
                  getTranslations(msg.msg, lang).then((translations) {
                    msg.translations = translations;
                    showTranslation(context, translations);
                  });
                },
                child: const Text("Translate"))
          ],
        ),
      ),
    );
  }
}
