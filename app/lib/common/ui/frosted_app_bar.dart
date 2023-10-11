import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? action;

  const FrostedAppBar({
    super.key,
    required this.title,
    this.action,
  });

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: 20, sigmaY: 16, tileMode: TileMode.mirror),
        child: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor:
              Theme.of(context).colorScheme.background.withOpacity(0.8),
          title: title,
          actions: action != null ? [action!] : null,
        ),
      ),
    );
  }
}
