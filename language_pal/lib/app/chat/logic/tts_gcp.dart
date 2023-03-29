import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

Future<String> generateTextToSpeech(String msg, ScenarioModel scenario) async {
  // Make post request to Google Cloud Text-to-Speech API
  print(scenario.voiceSettings);
  final data = (await FirebaseFunctions.instance
          .httpsCallable('generateTextToSpeech')
          .call({
    "language_code": scenario.voiceSettings["language_code"],
    "pitch": scenario.voiceSettings["pitch"],
    "voice_name": scenario.voiceSettings["name"],
    "text": msg,
  }))
      .data;
  final bytes = const Base64Decoder().convert(data, 0, data.length);
  final dir = await getTemporaryDirectory();
  final uuid = const Uuid().v4();
  String filePath = '${dir.path}/$uuid.mp3';
  final file = File(filePath);
  await file.writeAsBytes(bytes);

  return filePath;
}

class TTSButton extends StatefulWidget {
  ScenarioModel scenario;
  AIMsgModel msg;
  AudioPlayer audioPlayer;
  TTSButton(this.msg, this.audioPlayer, this.scenario, {super.key});

  @override
  State<TTSButton> createState() => _TTSButtonState();
}

class _TTSButtonState extends State<TTSButton> {
  bool loading = false;

  playAudio() async {
    await widget.audioPlayer.play(DeviceFileSource(widget.msg.audioPath!));
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: loading
          ? null
          : () async {
              if (widget.msg.audioPath != null) {
                playAudio();
                return;
              }
              setState(() {
                loading = true;
              });
              widget.msg.audioPath =
                  await generateTextToSpeech(widget.msg.msg, widget.scenario);
              setState(() {
                loading = false;
              });
              if (context.mounted) {
                playAudio();
              }
            },
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(),
            )
          : const Icon(Icons.volume_up, size: 18),
    );
  }
}
