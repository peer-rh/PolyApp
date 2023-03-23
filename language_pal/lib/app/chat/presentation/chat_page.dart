import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:language_pal/app/chat/logic/ai_msg.dart';
import 'package:language_pal/app/chat/logic/rating.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:language_pal/app/chat/presentation/components/chat_bubble.dart';
import 'package:language_pal/app/chat/presentation/components/input_area.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/common/lang_convert.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// TODO: Add Audio out
// TODO: Add Submit on keyboard not new line

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
          style: GoogleFonts.nunito(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
          child: Column(
            children: [
              // BannerAdWidget(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  reverse: true,
                  child: Column(
                    children: msgs.msgs.map((e) {
                      if (e is AIMsgModel) {
                        return AiMsgBubble(
                          e,
                          widget.scenario.avatar,
                        );
                      } else if (e is PersonMsgModel) {
                        return OwnMsgBubble(e);
                      } else {
                        return Container();
                      }
                    }).toList(),
                  ),
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
    msgs = Messages(SystemMessage(widget.scenario.prompt));
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
    getAIRespone(msgs.getLastMsgs()).then((resp) {
      setState(() {
        msgs.addMsg(AIMsgModel(resp.message));
        disabled = false;
      });
      _scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.bounceInOut);
    });
    getRating(
      widget.scenario.ratingDesc,
      widget.scenario.ratingName,
      (msgs.msgs[msgs.msgs.length - 2] as AIMsgModel).msg,
      personMsg.msg,
      convertLangCode(context.read<AuthProvider>().user!.ownLang),
      AppLocalizations.of(context)!.msg_rating_great,
      AppLocalizations.of(context)!.msg_rating_good,
      AppLocalizations.of(context)!.msg_rating_poor,
    ).then((resp) {
      setState(() {
        personMsg.rating = resp;
      });
    });
  }
}
