import 'package:flutter/material.dart';

class CustomCircularButton extends StatelessWidget {
  final Widget icon;
  final Function onPressed;
  final Color? color;
  final Color? outlineColor;
  final double? outlineWidth;
  final double size;

  const CustomCircularButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.outlineColor,
    this.outlineWidth,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPressed(),
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(size / 2),
              border: outlineColor != null
                  ? Border.all(
                      color: outlineColor!,
                      width: outlineWidth ?? 1,
                    )
                  : null),
          child: icon),
    );
  }
}
