import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/chat/presentation/chat_summary_page.dart';
import 'package:language_pal/app/chat/presentation/components/chat_bubble.dart';

class ChatBubbleColumn extends StatelessWidget {
  const ChatBubbleColumn({
    super.key,
    required this.msgs,
  });

  final Messages msgs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: msgs.msgs.map((e) {
            if (e is AIMsgModel) {
              return AiMsgBubble(
                e,
                msgs.scenario.avatar,
                msgs.scenario,
              );
            } else if (e is PersonMsgModel) {
              return OwnMsgBubble(e);
            } else {
              return Container();
            }
          }).toList(),
        ),
        if (msgs.rating != null)
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              child: GestureDetector(
                child: Text(
                  "This Conversation is Over. View your summary",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      decoration: TextDecoration.underline),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatSummaryPage(
                        msgs.rating!,
                      ),
                    ),
                  );
                },
              ))
      ],
    );
  }
}
