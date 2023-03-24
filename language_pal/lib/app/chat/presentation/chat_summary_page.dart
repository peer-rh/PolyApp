import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/logic/total_rating.dart';

class ChatSummaryPage extends StatelessWidget {
  ConversationRating rating;
  ChatSummaryPage(this.rating, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Summary'),
      ),
      body: Center(
        child: Text(rating.details),
      ),
    );
  }
}
