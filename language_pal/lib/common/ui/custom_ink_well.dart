import 'package:flutter/material.dart';

class CustomInkWell extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final void Function()? onTap;
  const CustomInkWell(
      {required this.child, required this.borderRadius, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      splashFactory: NoSplash.splashFactory,
      overlayColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      onTap: onTap,
      child: child,
    );
  }
}
