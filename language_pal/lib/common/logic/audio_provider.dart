import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

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

final cachedVoiceProvider = Provider<CachedVoiceProvider>((ref) {
  final ap = ref.watch(audioProvider);
  return CachedVoiceProvider(ap);
});

class CachedVoiceProvider {
  final AudioProvider ap;
  CachedVoiceProvider(this.ap);
  Map<String, String> cache = {};

  void play(String avatar, String langCode, String text) async {
    final thisId =
        md5.convert(utf8.encode("${langCode}_${avatar}_$text")).toString();
    if (cache.containsKey(thisId)) {
      ap.playLocal(cache[thisId]!);
    } else {
      final tmp = await getTemporaryDirectory();
      final file = File('${tmp.path}/$thisId.mp3');
      file.create(recursive: true);
      await FirebaseStorage.instance.ref("audio/$thisId.mp3").writeToFile(file);
      cache[thisId] = file.path;
      ap.playLocal(file.path);
    }
  }
}
