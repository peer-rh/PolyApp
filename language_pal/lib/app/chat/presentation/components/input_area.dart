import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceVariant),
                color: Theme.of(context).colorScheme.surface),
            alignment: Alignment.centerLeft,
            child: TextField(
              onSubmitted: (s) {
                if (s != "") {
                  widget.sendMsg(controller.text);
                  controller.text = "";
                }
              },
              controller: controller,
              textAlignVertical: TextAlignVertical.center,
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
          width: 10,
        ),
        IconButton(
          onPressed: () async {
            if (widget.disabled || controller.text == "") return;
            widget.sendMsg(controller.text);
            controller.text = "";
          },
          color: Theme.of(context).colorScheme.onPrimary,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(widget.disabled
                ? Theme.of(context).colorScheme.surfaceVariant
                : Theme.of(context).colorScheme.primary),
          ),
          icon: const FaIcon(FontAwesomeIcons.arrowUp),
        ),
      ],
    );
  }
}
