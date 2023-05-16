import 'package:flutter/material.dart';
import 'package:poly_app/common/ui/custom_circular_button.dart';
import 'package:poly_app/common/ui/custom_icons.dart';

class SendButton extends StatelessWidget {
  final void Function() onPressed;
  final bool enabled;
  const SendButton({required this.onPressed, required this.enabled, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCircularButton(
      icon: Icon(CustomIcons.arrow_up,
          color: Theme.of(context).colorScheme.onPrimary),
      onPressed: enabled ? onPressed : null,
      size: 32,
      color: enabled
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.primary.withOpacity(0.3),
    );
  }
}

class ChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? trailing;
  final void Function(String)? onSubmitted;

  const ChatTextField(
      {required this.controller,
      required this.hintText,
      this.onSubmitted,
      this.trailing,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
          color: Theme.of(context).colorScheme.background),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autocorrect: false,
              onSubmitted: onSubmitted,
              controller: controller,
              textAlignVertical: TextAlignVertical.center,
              maxLines: 5,
              minLines: 1,
              textInputAction: TextInputAction.send,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                hintText: hintText,
                border: InputBorder.none,
              ),
            ),
          ),
          trailing != null ? trailing! : const SizedBox(),
        ],
      ),
    );
  }
}
