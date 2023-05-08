import 'package:flutter/material.dart';

class CustomBox extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? minHeight;

  const CustomBox(
      {required this.child,
      this.backgroundColor,
      this.borderColor,
      this.borderWidth,
      this.minHeight,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints:
          minHeight != null ? BoxConstraints(minHeight: minHeight!) : null,
      padding: EdgeInsets.all(17 - (borderWidth ?? 1)),
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: (borderColor != null)
            ? Border.all(
                color: borderColor ?? Theme.of(context).colorScheme.surface,
                width: borderWidth ?? 1,
              )
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
