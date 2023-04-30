import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final Widget? trailing;

  FrostedAppBar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
  });

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 50),
        child: AppBar(
          backgroundColor:
              Theme.of(context).colorScheme.background.withOpacity(0.8),
          title: title,
          leading: leading,
          actions: trailing != null ? [trailing!] : null,
        ),
      ),
    );
  }
}
