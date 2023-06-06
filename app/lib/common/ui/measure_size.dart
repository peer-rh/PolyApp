import 'package:flutter/material.dart';

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSize extends StatefulWidget {
  final Widget child;
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    required this.onChange,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  MeasureSizeState createState() => MeasureSizeState();
}

class MeasureSizeState extends State<MeasureSize> {
  var widgetKey = GlobalKey();
  Size lastSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = widgetKey.currentContext!.size!;
      if (lastSize != size) {
        lastSize = size;
        widget.onChange(size);
      }
    });

    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }
}
