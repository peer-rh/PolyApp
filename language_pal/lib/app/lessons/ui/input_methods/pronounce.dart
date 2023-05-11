import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poly_app/app/lessons/ui/components/custom_box.dart';
import 'package:poly_app/common/logic/audio_visualizer.dart';
import 'package:poly_app/common/ui/audio_visualizer.dart';
import 'package:poly_app/common/ui/custom_circular_button.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:record/record.dart';
import 'package:sound_stream/sound_stream.dart';

class PronounciationInput extends StatefulWidget {
  final void Function(String) onSubmit;
  final bool disabled;
  final String wanted;
  const PronounciationInput(this.onSubmit, this.wanted,
      {this.disabled = false, super.key});

  @override
  State<PronounciationInput> createState() => _PronounciationInputState();
}

class _PronounciationInputState extends State<PronounciationInput> {
  bool loading = false;

  bool isRecording = false;
  final _fileRecord = Record();

  void record() {
    if (widget.disabled) return;
    setState(() {
      isRecording = true;
    });
    _fileRecord.start();
    Future.delayed(const Duration(seconds: 10), () {
      // TOOD: Alert what happened
      stop();
    });
  }

  void stop() async {
    // TODO: Have max len
    // TODO: Redo when wrong
    // TODO: Show loading
    setState(() {
      isRecording = false;
    });
    final file = await _fileRecord.stop();
    List<int> fileBytes = await File.fromUri(Uri.parse(file!)).readAsBytes();
    String base64String = base64Encode(fileBytes);
    final out = await FirebaseFunctions.instance
        .httpsCallable("getWhisperPronounciationResult")
        .call({
      "data": base64String,
      "language": "es",
      "text": widget.wanted,
    });
    widget.onSubmit(out.data);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBox(
        borderColor: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: AudioVisualizer(
              const Size(double.infinity, 100),
              isRecording,
            ),
          ),
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
                  onPressed: isRecording ? stop : record,
                  size: 48))
        ]));
  }
}
