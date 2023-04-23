import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/chat/logic/conversation_provider.dart';
import 'package:language_pal/app/chat/logic/get_ai_response.dart';
import 'package:language_pal/app/chat/ui/components/chat_bubble.dart';
import 'package:language_pal/app/chat/ui/components/conv_column.dart';
import 'package:language_pal/app/chat/ui/components/input_area.dart';
import 'package:language_pal/common/data/scenario_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatPage extends ConsumerStatefulWidget {
  final ScenarioModel scenario;
  const ChatPage({
    required this.scenario,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  Widget build(BuildContext context) {
    final conv = ref.watch(conversationProvider(widget.scenario));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.scenario.emoji} ${widget.scenario.name}",
        ),
        actions: [
          PopupMenuButton(
              itemBuilder: (context) => [
                    PopupMenuItem(
                        onTap: () async {
                          conv.reset();
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.refresh),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(AppLocalizations.of(context)!.chat_reset),
                          ],
                        ))
                  ])
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                      controller: _scrollController,
                      reverse: true,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      child: Column(
                        children: [
                          ConversationColumn(
                              conv: conv.conv, scenario: conv.scenario),
                          getBottomWidget()
                        ],
                      ))),
              const SizedBox(
                height: 10,
              ),
              ChatInputArea(
                scenario: conv.scenario,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget getBottomWidget() {
    final conv = ref.read(conversationProvider(widget.scenario));
    switch (conv.status) {
      case ConversationStatus.waitingForAIResponse:
        return AIMsgBubbleLoading(conv.scenario.avatar);
      case ConversationStatus.waitingForUserRedo:
        return Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              conv.getAIResponse();
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.reply, size: 14),
                  const SizedBox(width: 6),
                  Text(AppLocalizations.of(context)!.chat_page_send_anyways,
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        );
      case ConversationStatus.waitingForConvRating:
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 15, bottom: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.chat_page_end_loading,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    decoration: TextDecoration.underline),
              ),
              const SizedBox(width: 5),
              const SizedBox(
                  height: 14, width: 14, child: CircularProgressIndicator())
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }
}
