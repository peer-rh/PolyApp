import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat/data/messages.dart';
import 'package:poly_app/common/data/scenario_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

Future<String> generateTextToSpeech(
    String msg, Map<dynamic, dynamic> audioInfo) async {
  // Make post request to Google Cloud Text-to-Speech API
  final data = (await FirebaseFunctions.instance
          .httpsCallable('generateTextToSpeech')
          .call({
    "language_code": audioInfo["language_code"],
    "pitch": audioInfo["pitch"],
    "voice_name": audioInfo["name"],
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

class TTSButton extends ConsumerStatefulWidget {
  final Map<dynamic, dynamic> audioInfo;
  final AIMsgModel msg;
  final AudioPlayer audioPlayer;
  const TTSButton(this.msg, this.audioPlayer, this.audioInfo, {super.key});

  @override
  ConsumerState<TTSButton> createState() => _TTSButtonState();
}

class _TTSButtonState extends ConsumerState<TTSButton> {
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
                  await generateTextToSpeech(widget.msg.msg, widget.audioInfo);
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
