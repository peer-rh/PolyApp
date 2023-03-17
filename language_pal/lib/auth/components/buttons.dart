// Sign in Button with option for google, apple and default
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final Color color;

  const AuthButton(this.onPressed, this.text, this.color, {super.key});
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
