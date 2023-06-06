import 'dart:math' as math show sin, pi;

import 'package:flutter/material.dart';

class LoadingThreeDots extends StatefulWidget {
  final Color color;
  const LoadingThreeDots({required this.color, super.key});

  @override
  State<LoadingThreeDots> createState() => _LoadingThreeDotsState();
}

class _LoadingThreeDotsState extends State<LoadingThreeDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.addListener(() {
      setState(() {});
    });
    _controller.repeat();
    super.initState();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return ScaleTransition(
          scale: DelayTween(begin: 0.0, end: 1.0, delay: i * .2)
              .animate(_controller),
          child: SizedBox.fromSize(
              size: const Size.square(12),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: widget.color, shape: BoxShape.circle))),
        );
      }),
    );
  }
}

class DelayTween extends Tween<double> {
  DelayTween({double? begin, double? end, required this.delay})
      : super(begin: begin, end: end);

  final double delay;

  @override
  double lerp(double t) =>
      super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}
