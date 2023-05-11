import 'package:flutter/material.dart';

class AIAvatar extends StatelessWidget {
  final String avatar;
  const AIAvatar(this.avatar, {super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      foregroundImage: AssetImage(
        "assets/avatars/$avatar",
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}
