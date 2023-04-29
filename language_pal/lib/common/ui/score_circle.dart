import 'package:flutter/material.dart';

class ScoreCircle extends CustomPainter {
  final int score;
  final double strokeWidth;
  final BuildContext context;
  const ScoreCircle(this.score, this.context, {this.strokeWidth = 10});

  @override
  void paint(Canvas canvas, Size size) {
    var paintBg = Paint()
      ..color = Theme.of(context).colorScheme.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    var paintFg = Paint()
      ..color = Theme.of(context).colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    var fullCircle = Path();
    final adjustedHeight = size.height - strokeWidth * 2;
    fullCircle.addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: adjustedHeight / 2));

    var arc = Path();
    arc.addArc(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: adjustedHeight / 2),
        -3.14 / 2,
        3.14 * 2 * (score / 10));

    canvas.drawPath(fullCircle, paintBg);
    canvas.drawPath(arc, paintFg);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
