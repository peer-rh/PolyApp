import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/logic/ai_msg.dart';
import 'package:language_pal/app/chat/logic/rating.dart';
import 'package:language_pal/app/chat/logic/total_rating.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/chat/presentation/chat_summary_page.dart';
import 'package:language_pal/app/chat/presentation/components/chat_bubble_scroll.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:language_pal/app/chat/presentation/components/input_area.dart';
import 'package:language_pal/app/user/logic/past_conversations.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/common/fade_route.dart';
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
  late Messages msgs;

  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  bool disabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.scenario.emoji} ${widget.scenario.name}",
        ),
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
                  child: ChatBubbleColumn(msgs: msgs),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ChatInputArea(
                sendMsg: _addMsg,
                disabled: disabled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    msgs = Messages(widget.scenario);
    initalFetchAIMsg();
  }

  void initalFetchAIMsg() async {
    String msg = widget.scenario
        .startMessages[Random().nextInt(widget.scenario.startMessages.length)];
    setState(() {
      msgs.addMsg(AIMsgModel(msg));
      disabled = false;
    });
  }

  void _addMsg(String msg) async {
    PersonMsgModel personMsg = PersonMsgModel(msg);
    setState(() {
      msgs.addMsg(personMsg);
      disabled = true;
    });
    if (msgs.rating != null) return;
    getAIRespone(msgs.getLastMsgs()).then((resp) {
      setState(() {
        msgs.msgs[msgs.msgs.length - 1] = AIMsgModel(resp.message);
        disabled = false;
      });
      _scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.bounceInOut);
      if (resp.endOfConversation) {
        getSummary();
      }
    });
    getRating(
      widget.scenario.ratingDesc,
      widget.scenario.ratingName,
      msgs,
      context.read<AuthProvider>().user!.appLang,
      AppLocalizations.of(context)!.msg_rating_great,
      AppLocalizations.of(context)!.msg_rating_good,
      AppLocalizations.of(context)!.msg_rating_poor,
    ).then((resp) {
      setState(() {
        personMsg.rating = resp;
      });
    });
    setState(() {
      msgs.addMsg(AIMsgModel("")..loaded = false);
    });
  }

  void getSummary() async {
    sleep(const Duration(seconds: 8));
    final rating = await getConversationRating(
        widget.scenario.ratingDesc,
        widget.scenario.ratingName,
        context.read<AuthProvider>().user!.appLang,
        msgs);
    setState(() {
      msgs.rating = rating;
    });

    addConversationToFirestore(msgs, context.read<AuthProvider>());
    Navigator.push(context, FadeRoute(ChatSummaryPage(rating)));
  }
}
