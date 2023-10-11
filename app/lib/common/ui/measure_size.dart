import 'package:flutter/widgets.dart';

typedef OnWidgetSizeChange = void Function(Size size);

class ResizeObserver extends StatefulWidget {
  final Widget child;
  final OnWidgetSizeChange onResized;

  const ResizeObserver({
    required this.onResized,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  ResizeObserverState createState() => ResizeObserverState();
}

class ResizeObserverState extends State<ResizeObserver> {
  var widgetKey = GlobalKey();
  bool sent = false;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sent) return;
      final size = widgetKey.currentContext!.size!;
      widget.onResized(size);
      sent = true;
    });

    return NotificationListener(
      onNotification: (notification) {
        widget.onResized(widgetKey.currentContext!.size!);
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Container(
          key: widgetKey,
          child: widget.child,
        ),
      ),
    );
  }
}
