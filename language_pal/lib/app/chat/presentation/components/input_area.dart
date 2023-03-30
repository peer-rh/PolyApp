import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatInputArea extends StatefulWidget {
  ValueSetter<String> sendMsg;
  bool disabled;
  String hint;

  ChatInputArea(
      {Key? key,
      required this.hint,
      required this.sendMsg,
      required this.disabled})
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
  void initState() {
    super.initState();
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
                if (widget.disabled) return;
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
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        GestureDetector(
          onTap: () async {
            if (widget.disabled) return;
            widget.sendMsg(controller.text);
            controller.text = "";
          },
          child: Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: widget.disabled
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Theme.of(context).colorScheme.primary),
            child: FaIcon(
              FontAwesomeIcons.arrowUp,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        )
      ],
    );
  }
}
