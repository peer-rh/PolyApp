import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final String text;
  const CustomDivider({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(
          child: Divider(),
        ),
        const SizedBox(
          width: 8,
        ),
        Text(text),
        const SizedBox(
          width: 8,
        ),
        const Expanded(
          child: Divider(),
        ),
      ],
    );
  }
}
