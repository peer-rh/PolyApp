import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class OwnMsgBubble extends StatelessWidget {
  final String msg;
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
        child: Text(
          msg,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}

class AiMsgBubble extends StatelessWidget {
  final String msg;
  const AiMsgBubble(this.msg, {super.key});

  Future<String> getTranslation() async {
    // Call the getTranslation cloud function
    return (await FirebaseFunctions.instance
            .httpsCallable('getTranslation')
            .call(msg))
        .data
        .toString();
  }

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
              msg,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            TextButton(
                onPressed: () async {
                  // TODO: Come up with better Solution
                  String translation = await getTranslation();
                  showTranslation(context, translation);
                },
                child: const Text("Translate"))
          ],
        ),
      ),
    );
  }
}
