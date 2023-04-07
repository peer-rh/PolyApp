import 'dart:math';

import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/logic/ai_msg.dart';
import 'package:language_pal/app/chat/logic/rating.dart';
import 'package:language_pal/app/chat/logic/store_conv.dart';
import 'package:language_pal/app/chat/logic/total_rating.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/chat/presentation/chat_summary_page.dart';
import 'package:language_pal/app/chat/presentation/components/chat_bubble_scroll.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:language_pal/app/chat/presentation/components/input_area.dart';
import 'package:language_pal/app/user/logic/past_conversations.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/common/fade_route.dart';
import 'package:language_pal/common/languages.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatPage extends StatefulWidget {
  final ScenarioModel scenario;
  const ChatPage({
    Key? key,
    required this.scenario,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Conversation msgs;

  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  Widget build(BuildContext context) {
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
                          await deleteConv(widget.scenario);
                          setState(() {
                            msgs = Conversation(widget.scenario);
                          });
                          initChat();
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
                  child: ChatBubbleColumn(
                    msgs: msgs,
                    sendAnyways:
                        msgs.state == ConversationState.waitingForUserRedo
                            ? sendAnyways
                            : null,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ChatInputArea(
                sendMsg: _addMsg,
                conv: msgs,
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
    if (msgs.rating == null) storeConv(msgs);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    msgs = Conversation(widget.scenario);
    initChat();
  }

  void sendAnyways() {
    getAIMsg();
    setState(() {
      msgs.state = ConversationState.waitingForAIMsg;
    });
  }

  void initChat() async {
    Conversation? storedConv = await loadConv(widget.scenario);
    if (storedConv != null) {
      msgs = storedConv;
      if (msgs.state == ConversationState.waitingForAIMsg) {
        msgs.msgs.removeLast();
        getAIMsg();
      } else if (msgs.state == ConversationState.waitingForRating) {
        getMsgRating(msgs.msgs.last as PersonMsgModel);
      }
      setState(() {});
    } else {
      String msg = widget.scenario.startMessages[
          Random().nextInt(widget.scenario.startMessages.length)];
      setState(() {
        msgs.addMsg(AIMsgModel(msg));
        msgs.addMsg(PersonMsgModel([]));
        msgs.state = ConversationState.waitingForUserMsg;
      });
    }
  }

  void _addMsg(String msg, bool check) async {
    if (msgs.msgs.last is! PersonMsgModel) {
      msgs.addMsg(PersonMsgModel([]));
    }
    PersonMsgModel personMsg = msgs.msgs.last as PersonMsgModel;
    if (check) {
      setState(() {
        personMsg.msgs.add(SingularPersonMsgModel(msg));
        msgs.state = ConversationState.waitingForRating;
      });
      getMsgRating(personMsg);
    } else {
      setState(() {
        personMsg.msgs.add(SingularPersonMsgModel(msg));
        msgs.state = ConversationState.waitingForAIMsg;
      });
      getAIMsg();
    }
  }

  void getMsgRating(PersonMsgModel personMsg) {
    getRating(
      msgs,
      convertLangCode(context.read<AuthProvider>().user!.appLang)
          .getEnglishName(),
    ).then((resp) {
      setState(() {
        personMsg.msgs.last.rating = resp;
      });
      if (resp.type == MsgRatingType.correct) {
        setState(() {
          msgs.state = ConversationState.waitingForAIMsg;
        });
        getAIMsg();
      } else {
        setState(() {
          msgs.state = ConversationState.waitingForUserRedo;
        });
      }
    });
  }

  void getAIMsg() async {
    if (msgs.rating != null) return;
    setState(() {
      msgs.addMsg(AIMsgModel("")..loaded = false);
    });
    getAIResponse(msgs.getLastMsgs(10)).then((resp) {
      setState(() {
        msgs.msgs[msgs.msgs.length - 1] = AIMsgModel(resp.message);
        msgs.state = ConversationState.waitingForUserMsg;
      });
      _scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.bounceInOut);
      if (resp.endOfConversation) {
        setState(() {
          msgs.state = ConversationState.finished;
        });
        getSummary();
      }
    });
  }

  void getSummary() async {
    final rating = await getConversationRating(
        context.read<AuthProvider>().user!.appLang, msgs);
    setState(() {
      msgs.rating = rating;
    });

    deleteConv(widget.scenario);
    addConversationToFirestore(msgs, context.read<AuthProvider>());
    Navigator.push(context, FadeRoute(ChatSummaryPage(rating)));
  }
}
