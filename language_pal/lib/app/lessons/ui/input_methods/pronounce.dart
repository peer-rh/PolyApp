import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poly_app/app/lessons/ui/components/custom_box.dart';
import 'package:poly_app/common/logic/get_audio_vis.dart';
import 'package:poly_app/common/ui/audio_visualizer.dart';
import 'package:poly_app/common/ui/custom_circular_button.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:sound_stream/sound_stream.dart';

class PronounciationInput extends StatefulWidget {
  final void Function(String) onSubmit;
  final bool disabled;
  const PronounciationInput(this.onSubmit, {this.disabled = false, super.key});

  @override
  State<PronounciationInput> createState() => _PronounciationInputState();
}

class _PronounciationInputState extends State<PronounciationInput> {
  bool loading = false;

  static const int bufferSize = 2048;
  static const int sampleRate = 44100;

  final RecorderStream _recorder = RecorderStream();
  late StreamSubscription _recorderStatus;
  late StreamSubscription _audioStream;

  bool isRecording = false;
  bool isPlaying = false;
  final List<Uint8List> _micChunks = [];

  final viz = AudioVisualizer(
    windowSize: bufferSize,
    bandType: BandType.EightBand,
    sampleRate: sampleRate,
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
    cleanUp();
    super.dispose();
  }

  Future<void> init() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }

    _recorderStatus = _recorder.status.listen((status) {
      if (mounted) {
        setState(() {
          isRecording = status == SoundStreamStatus.Playing;
          if (status == SoundStreamStatus.Stopped) {
            audioFFT.add(null);
          }
        });
      }
    });

    _audioStream = _recorder.audioStream.listen((data) {
      _micChunks.add(data);
      audioFFT.add(viz.transform(data, minRange: 0, maxRange: 255));
    });

    await _recorder.initialize();
  }

  Future<void> cleanUp() async {
    await _recorderStatus.cancel();
    await _audioStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final visualizer = StreamBuilder(
        stream: audioFFT.stream,
        builder: (context, snapshot) {
          final buffer = snapshot.data ?? List.filled(8, 0.0);
          final wave = buffer.map((e) => max(0.0, e - 0.15)).toList();

          return CustomPaint(
            painter: BarVisualizer(
              waveData: wave,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const SizedBox(width: double.infinity, height: 64),
          );
        });
    return CustomBox(
        borderColor: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: visualizer),
          const SizedBox(height: 16),
          Align(
              alignment: Alignment.topCenter,
              child: CustomCircularButton(
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icon(
                    !isRecording ? CustomIcons.mic : CustomIcons.check,
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: isRecording ? _recorder.stop : _recorder.start,
                  size: 48))
        ]));
  }
}
