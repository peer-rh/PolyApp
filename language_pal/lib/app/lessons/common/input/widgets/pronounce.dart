import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:poly_app/app/lessons/common/ui.dart';
import 'package:poly_app/app/lessons/common/util.dart';
import 'package:poly_app/common/ui/audio_visualizer.dart';
import 'package:poly_app/common/ui/custom_circular_button.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:record/record.dart';

class PronounciationInput extends StatefulWidget {
  final void Function(String) onAnswer;
  final bool disabled;
  final String wanted;
  final void Function() onSubmit;
  final void Function() onSkip;
  const PronounciationInput(
      this.onAnswer, this.onSubmit, this.onSkip, this.wanted,
      {this.disabled = false, super.key});

  @override
  State<PronounciationInput> createState() => _PronounciationInputState();
}

class _PronounciationInputState extends State<PronounciationInput> {
  bool loading = false;
  bool skip = false;

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
    setState(() {
      loading = true;
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
    if (getNormifiedString(out.data) == getNormifiedString(widget.wanted)) {
      widget.onAnswer(out.data);
      widget.onSubmit();
    } else {
      skip = true;
    }
    setState(() {
      loading = false;
    });
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
                  icon: loading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : Icon(
                          !isRecording ? CustomIcons.mic : CustomIcons.check,
                          size: 24,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  onPressed: loading
                      ? null
                      : isRecording
                          ? stop
                          : record,
                  size: 48)),
          const SizedBox(height: 16),
          if (skip) const Text("Try again"),
          if (skip)
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onSkip,
                child: Text("Skip",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
              ),
            )
        ]));
  }
}
