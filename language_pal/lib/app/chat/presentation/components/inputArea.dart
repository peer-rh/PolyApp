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
  stt.SpeechToText? speech;

  @override
  void dispose() {
    speech = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.addListener(() => setState(() {
          controller.text == "" ? showMic = true : showMic = false;
        }));
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                decoration: const InputDecoration(
                  hintText: "Write message...",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          GestureDetector(
            onTapDown: (_) async {
              if (widget.disabled) return;
              if (showMic) {
                print("Start listening");
                speech = stt.SpeechToText();
                bool available =
                    await speech!.initialize(onStatus: (s) {}, onError: (e) {});
                if (available) {
                  speech!.listen(
                      onResult: (s) {
                        setState(() {
                          controller.text = s.recognizedWords;
                        });
                      },
                      localeId: "de-DE");
                } else {
                  print("The user has denied the use of speech recognition.");
                }
              }
            },
            onTapUp: (_) {
              if (widget.disabled) return;
              if (showMic && speech != null) {
                print("Finished Listening");
                speech!.stop();
              } else {
                widget.sendMsg(controller.text);
                controller.text = "";
              }
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: widget.disabled ? Colors.grey : Colors.blue,
                  shape: BoxShape.circle),
              child: Icon(
                showMic ? Icons.mic : Icons.send,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
