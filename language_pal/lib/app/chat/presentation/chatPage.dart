// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:language_pal/app/ads/bannerAd.dart';
import 'package:language_pal/app/ads/rewardAd.dart';
import 'package:language_pal/app/chat/logic/aiMsg.dart';
import 'package:language_pal/app/chat/logic/grammar.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/chat/models/scenariosModel.dart';
import 'package:language_pal/app/chat/presentation/components/chatBubble.dart';
import 'package:language_pal/app/chat/presentation/components/inputArea.dart';
import 'package:language_pal/app/user/userProvider.dart';
import 'package:language_pal/auth/authProvider.dart';
import 'package:provider/provider.dart';

// TODO: Add Audio out
// TODO: Add Submit on keyboard not new line

class ChatPage extends StatefulWidget {
  final ScenarioModel scenario;
  final String ownLang;
  final String learnLang;
  ChatPage(
      {Key? key,
      required this.scenario,
      required this.ownLang,
      required this.learnLang})
      : super(key: key);

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
        title: Text(widget.scenario.name),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 15, left: 15, right: 15),
          child: Column(
            children: [
              BannerAdWidget(),
              FilledButton(
                  onPressed: () => showAlertMsg(context),
                  child: Text("Reward")),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  reverse: true,
                  child: Column(
                    children: msgs.msgs.map((e) {
                      if (e is AIMsgModel) {
                        return AiMsgBubble(e, widget.ownLang);
                      } else if (e is PersonMsgModel) {
                        return OwnMsgBubble(e);
                      } else {
                        return Container();
                      }
                    }).toList(),
                  ),
                ),
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
    ParserResult res = parseAIMsg(widget.scenario.startMessages[0]);
    setState(() {
      msgs.addMsg(AIMsgModel(res.message, widget.scenario.startMessages[0]));
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
        personMsg.relevancyScore = resp.relevancyScore;
        msgs.addMsg(AIMsgModel(resp.message, resp.actualMessage));
        disabled = false;
      });
      _scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
    });
    print("Called Get Grammar");
    getGrammarCorrection(personMsg.msg).then((resp) {
      setState(() {
        personMsg.grammarCorrection = resp;
      });
    });
  }
}
