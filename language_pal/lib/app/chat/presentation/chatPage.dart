// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:language_pal/app/ads/bannerAd.dart';
import 'package:language_pal/app/ads/rewardAd.dart';
import 'package:language_pal/app/chat/components/chatBubble.dart';
import 'package:language_pal/app/chat/components/inputArea.dart';
import 'package:language_pal/app/chat/messagesModel.dart';
import 'package:language_pal/app/chat/scenariosModel.dart';

// TODO: Add Audio out
// TODO: Add Submit on keyboard not new line

class ChatPage extends StatefulWidget {
  final ScenarioModel scenario;
  const ChatPage({Key? key, required this.scenario}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  MessageList msgs = MessageList();
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  bool disabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.scenario.name}"),
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
                      if (e.role == "user") {
                        return OwnMsgBubble(e.msg);
                      } else if (e.role == "assistant") {
                        return AiMsgBubble(e.msg);
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

  void fetchChatGPT() async {
    setState(() {
      disabled = true;
    });
    await msgs.fetchAnswer(); // Maybe it doesnt update
    setState(() {
      disabled = false;
    });
  }

  @override
  void initState() {
    super.initState();
    msgs.addMsg(Message(role: "system", msg: widget.scenario.prompt));
    msgs.addMsg(Message(
        role: "assistant",
        msg: widget.scenario.beginningMsgs[0])); // TODO: Make random
  }

  void _addMsg(String msg) {
    setState(() {
      msgs.addMsg(Message(role: "user", msg: msg));
    });
    fetchChatGPT();
    _scrollController.animateTo(0.0,
        duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
  }
}
