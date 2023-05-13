import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void play(String audioPath) async {
    if (cache.containsKey(audioPath)) {
      ap.playLocal(cache[audioPath]!);
    } else {
      final tmp = await getTemporaryDirectory();
      final file = File('${tmp.path}/$audioPath');
      file.create(recursive: true);
      await FirebaseStorage.instance.ref(audioPath).putFile(file);
      cache[audioPath] = file.path;
      ap.playLocal(file.path);
    }
  }
}
