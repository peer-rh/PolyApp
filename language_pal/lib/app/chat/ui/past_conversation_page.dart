import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/chat/data/conversation.dart';
import 'package:language_pal/app/chat/logic/past_conversation_provider.dart';
import 'package:language_pal/app/chat/ui/components/conv_column.dart';
import 'package:language_pal/app/user/ui/select_learn_lang.dart';
import 'package:language_pal/common/logic/scenario_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PastConversationListPage extends ConsumerWidget {
  const PastConversationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Conversation> convs = ref.watch(pastConversationProvider);
    bool loadingConvs = ref.watch(pastConversationProvider.notifier).loading;

    List<Widget> convsList = convs.map((conv) {
      final scenario = ref.read(scenarioProvider)[conv.scenarioId];
      if (scenario == null) {
        FirebaseCrashlytics.instance.recordError(
            Exception("Scenario ${conv.scenarioId}not found"),
            StackTrace.current);
        return const SizedBox();
      }
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PastConversationPage(conv: conv)));
        },
        child: Card(
          child: ListTile(
            leading: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(scenario.emoji),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      value: (conv.rating?.totalScore ?? 0) / 10,
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ]),
            title: Text(scenario.name),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const SelectLearnLangTitle()),
      body: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.past_conversations_title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    if (loadingConvs)
                      const CircularProgressIndicator()
                    else if (convs.isEmpty)
                      Text(
                        AppLocalizations.of(context)!
                            .user_page_no_conversations,
                        style: Theme.of(context).textTheme.headlineSmall,
                      )
                    else
                      ...convsList
                  ]))),
    );
  }
}

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
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
        child: SingleChildScrollView(
          reverse: true,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: ConversationColumn(conv: conv, scenario: scenario),
          ),
        ),
      ),
    );
  }
}
