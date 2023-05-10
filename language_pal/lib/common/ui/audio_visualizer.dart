import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class AudioBars extends CustomPainter {
  final List<double> waveData;
  final Color color;
  final Paint wavePaint;
  final double barWidth;

  AudioBars({
    required this.waveData,
    required this.color,
    this.barWidth = 8.0,
  }) : wavePaint = Paint()
          ..strokeWidth = barWidth
          ..strokeCap = StrokeCap.round
          ..color = color.withOpacity(1.0)
          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final heightCenter = height / 2;
    final xOffset = width / (waveData.length - 1);
    for (int i = 0; i < waveData.length; i++) {
      double dy = heightCenter * waveData[i];
      double x = i * xOffset;
      canvas.drawLine(Offset(x, heightCenter - dy),
          Offset(x, heightCenter + dy), wavePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
