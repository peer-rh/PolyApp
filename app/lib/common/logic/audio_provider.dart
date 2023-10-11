import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poly_app/common/logic/languages.dart';
import 'package:uuid/uuid.dart';

final audioProvider = Provider<AudioProvider>((ref) {
  return AudioProvider();
});

class AudioProvider {
  bool isPlaying = false;
  late AudioPlayer audioPlayer;

  AudioProvider() {
    audioPlayer = AudioPlayer();
    initAudio();
  }

  void initAudio() async {
    await audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    await AudioPlayer.global.setGlobalAudioContext(const AudioContext(
        iOS: AudioContextIOS(options: [
          AVAudioSessionOptions.allowBluetooth,
          AVAudioSessionOptions.allowBluetoothA2DP,
          AVAudioSessionOptions.allowAirPlay,
          AVAudioSessionOptions.duckOthers,
        ]),
        android: AudioContextAndroid()));
  }

  void playNet(String url) async {
    await stop();
    await audioPlayer.play(UrlSource(url));
  }

  void playLocal(String asset) async {
    await stop();
    await audioPlayer.play(DeviceFileSource(asset));
  }

  Future<void> stop() async {
    await audioPlayer.stop();
  }
}

final useCachedVoice = StateProvider<bool>((ref) => true);

final voiceProvider = Provider<VoiceProvider>((ref) {
  final ap = ref.watch(audioProvider);

  return VoiceProvider(
      ap, ref.watch(useCachedVoice), ref.watch(learnLangProvider));
});

class VoiceProvider {
  final AudioProvider ap;
  final bool useFirestore;
  final LanguageModel learnLang;
  VoiceProvider(this.ap, this.useFirestore, this.learnLang);
  final Map<String, String> cacheFirestore = {};
  final Map<({Map<String, dynamic> voiceSettings, String txt}), String>
      cacheTTS = {};

  void play(String text, {String? avatar}) async {
    if (useFirestore) {
      _playFirestore(avatar ?? "random", learnLang.code, text);
    } else {
      playTTS(learnLang.defaultVoice, text);
    }
  }

  Future<void> playTTS(Map<String, dynamic> voiceSettings, String text) async {
    final key = (voiceSettings: voiceSettings, txt: text);

    if (cacheTTS.containsKey(key)) {
      ap.playLocal(cacheTTS[key]!);
      return;
    }
    final audio =
        await FirebaseFunctions.instance.httpsCallable("text2Speech")({
      "language_code": voiceSettings["language_code"],
      "voice_name": voiceSettings["name"],
      "pitch": voiceSettings["pitch"],
      "text": text,
    });
    final data =
        const Base64Decoder().convert(audio.data, 0, audio.data.length);
    final dir = await getTemporaryDirectory();
    final uuid = const Uuid().v4();
    String filePath = '${dir.path}/$uuid.mp3';
    final file = File(filePath);
    await file.writeAsBytes(data);
    cacheTTS[key] = filePath;
    ap.playLocal(filePath);
  }

  void _playFirestore(String avatar, String langCode, String text) async {
    final thisId =
        md5.convert(utf8.encode("${langCode}_${avatar}_$text")).toString();
    if (cacheFirestore.containsKey(thisId)) {
      ap.playLocal(cacheFirestore[thisId]!);
    } else {
      final tmp = await getTemporaryDirectory();
      final file = File('${tmp.path}/$thisId.mp3');
      file.create(recursive: true);
      await FirebaseStorage.instance.ref("audio/$thisId.mp3").writeToFile(file);
      cacheFirestore[thisId] = file.path;
      ap.playLocal(file.path);
    }
  }
}
