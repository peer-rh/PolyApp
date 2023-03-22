import 'package:flutter/material.dart';

class CustomAuthButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  const CustomAuthButton(
      {required this.text, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size.fromHeight(40))),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
