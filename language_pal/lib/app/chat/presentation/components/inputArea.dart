import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatInputArea extends StatefulWidget {
  ValueSetter<String> sendMsg;
  bool disabled;

  ChatInputArea({Key? key, required this.sendMsg, required this.disabled})
      : super(key: key);

  @override
  State<ChatInputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<ChatInputArea> {
  final controller = TextEditingController();
  var showMic = true;

  @override
  Widget build(BuildContext context) {
    controller.addListener(() => setState(() {
          controller.text == "" ? showMic = true : showMic = false;
        }));
    return Container(
      width: double.infinity,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), color: Colors.white),
              alignment: Alignment.centerLeft,
              child: TextField(
                onSubmitted: (s) {
                  if (s != "") {
                    widget.sendMsg(controller.text);
                    controller.text = "";
                  }
                },
                controller: controller,
                textAlignVertical: TextAlignVertical.bottom,
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: "Write message...",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          FloatingActionButton(
            onPressed: () async {
              if (widget.disabled) return;
              // TODO: Maybe use input default method
              // TODO: Or build Tensorflow Model to also correct pronounciation
              // TODO: Use Button Hold Down
              // BUG: Quick Double Press emediatly sends text
              if (showMic) {
                stt.SpeechToText speech = stt.SpeechToText();
                bool available =
                    await speech.initialize(onStatus: (s) {}, onError: (e) {});
                if (available) {
                  speech.listen(
                      onResult: (s) {
                        setState(() {
                          controller.text = s.recognizedWords;
                        });
                      },
                      localeId: "de-DE");
                } else {
                  print("The user has denied the use of speech recognition.");
                }
                // some time later...
                sleep(Duration(seconds: 5));
                speech.stop();
              } else {
                widget.sendMsg(controller.text);
                controller.text = "";
              }
            },
            backgroundColor: widget.disabled ? Colors.grey : Colors.blue,
            elevation: 0,
            child: Icon(
              showMic ? Icons.mic : Icons.send,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
