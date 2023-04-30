import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedEffect extends StatelessWidget {
  final Widget child;
  const FrostedEffect({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 50),
      child: Container(
          color: Theme.of(context).colorScheme.background.withOpacity(0.8),
          child: child),
    ));
  }
}
