import 'package:flutter/material.dart';

class Flag extends StatelessWidget {
  final String code;
  const Flag({required this.code, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage("assets/flags/$code.png"),
        ),
      ),
    );
  }
}
