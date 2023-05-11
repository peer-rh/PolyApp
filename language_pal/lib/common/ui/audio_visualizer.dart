import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poly_app/common/logic/audio_visualizer.dart';
import 'package:sound_stream/sound_stream.dart';

class AudioVisualizer extends StatefulWidget {
  static const int bufferSize = 2048;
  static const int sampleRate = 16000;
  final Size size;
  final bool recording;

  const AudioVisualizer(this.size, this.recording, {super.key});

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> {
  final recorder = RecorderStream();

  late StreamSubscription _audioStream;

  final viz = AudioVisualizerTransformer(
    windowSize: AudioVisualizer.bufferSize,
    bandType: BandType.EightBand,
    sampleRate: AudioVisualizer.sampleRate,
    zeroHzScale: 0.05,
    fallSpeed: 0.08,
    sensibility: 8.0,
  );

  StreamController<List<double>?> audioFFT = StreamController<List<double>?>();

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _audioStream.cancel();
    super.dispose();
  }

  Future<void> init() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }

    _audioStream = recorder.audioStream.listen((data) {
      audioFFT.add(viz.transform(data, minRange: 0, maxRange: 255));
    });

    await recorder.initialize();
  }

  void record() async {
    await recorder.start();
  }

  void stop() async {
    await recorder.stop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recording == true) {
      record();
    } else {
      stop();
    }
    return StreamBuilder(
        stream: audioFFT.stream,
        builder: (context, snapshot) {
          final buffer =
              (widget.recording ? snapshot.data : null) ?? List.filled(8, 0.0);
          final wave = buffer.map((e) => max(0.0, e - 0.15)).toList();

          return CustomPaint(
            painter: AudioBars(
              waveData: wave,
              color: Theme.of(context).colorScheme.primary,
            ),
            child:
                SizedBox(width: widget.size.width, height: widget.size.height),
          );
        });
  }
}

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
