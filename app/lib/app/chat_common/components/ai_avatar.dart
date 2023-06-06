import 'package:flutter/material.dart';

class AIAvatar extends StatelessWidget {
  final String avatar;
  final double radius;
  const AIAvatar(this.avatar, {this.radius = 20, super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      foregroundImage: AssetImage(
        "assets/avatars/$avatar.png",
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}
