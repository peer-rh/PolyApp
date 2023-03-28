import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/chat/presentation/components/chat_bubble_scroll.dart';

class PastConversationPage extends StatelessWidget {
  final Messages msgs;
  const PastConversationPage(this.msgs, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${msgs.scenario.emoji} ${msgs.scenario.name}",
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: ChatBubbleColumn(msgs: msgs),
        ),
      ),
    );
  }
}
