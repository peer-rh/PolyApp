import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double height;
  const Logo(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: Image.asset("assets/logo.png"));
  }
}
