import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
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
