import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    if (isPlaying) return;
    isPlaying = true;
    await audioPlayer.play(UrlSource(url));
    isPlaying = false;
  }

  void playLocal(String asset) async {
    if (isPlaying) return;
    isPlaying = true;
    await audioPlayer.play(DeviceFileSource(asset));
    isPlaying = false;
  }
}
