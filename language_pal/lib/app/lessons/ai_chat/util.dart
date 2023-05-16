import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poly_app/app/learn_track/logic/learn_track_provider.dart';
import 'package:poly_app/common/logic/audio_provider.dart';
import 'package:uuid/uuid.dart';

final translationProvider =
    FutureProvider.family<String, String>((ref, learnLang) async {
  final appLang = ref.watch(appLangProvider);
  final translation = await FirebaseFunctions.instance.httpsCallable(
      "translate")({"text": learnLang, "target": appLang.englishName});
  return translation.data;
});

final ttsProvider = Provider<TTSProvider>((ref) {
  final audio = ref.watch(audioProvider);
  return TTSProvider(audio);
});

class TTSProvider {
  final Map<({Map<String, dynamic> voiceSettings, String txt}), String> _cache =
      {};
  final AudioProvider _audioProvider;

  TTSProvider(this._audioProvider);

  Future<void> speak(Map<String, dynamic> voiceSettings, String txt) async {
    final key = (voiceSettings: voiceSettings, txt: txt);
    if (_cache.containsKey(key)) {
      _audioProvider.playLocal(_cache[key]!);
      return;
    }
    final audio =
        await FirebaseFunctions.instance.httpsCallable("text2Speech")({
      "language_code": voiceSettings["language_code"],
      "voice_name": voiceSettings["name"],
      "pitch": voiceSettings["pitch"],
      "text": txt,
    });
    final data =
        const Base64Decoder().convert(audio.data, 0, audio.data.length);
    final dir = await getTemporaryDirectory();
    final uuid = const Uuid().v4();
    String filePath = '${dir.path}/$uuid.mp3';
    final file = File(filePath);
    await file.writeAsBytes(data);
    _cache[key] = filePath;
    _audioProvider.playLocal(filePath);
  }
}
