import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/chat/data/conversation.dart';
import 'package:language_pal/app/chat/ui/components/conv_column.dart';
import 'package:language_pal/common/logic/scenario_provider.dart';

class PastConversationPage extends ConsumerWidget {
  final Conversation conv;
  const PastConversationPage({required this.conv, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenario = ref.watch(scenarioProvider)[conv.scenarioId]!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${scenario.emoji} ${scenario.name}",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
          child: Expanded(
            child: SingleChildScrollView(
              reverse: true,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: ConversationColumn(conv: conv, scenario: scenario),
            ),
          ),
        ),
      ),
    );
  }
}
