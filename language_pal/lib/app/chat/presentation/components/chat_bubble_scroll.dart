import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/chat/presentation/chat_summary_page.dart';
import 'package:language_pal/app/chat/presentation/components/chat_bubble.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatBubbleColumn extends StatelessWidget {
  AudioPlayer audioPlayer = AudioPlayer();
  ChatBubbleColumn({
    super.key,
    required this.msgs,
  });

  final Messages msgs;

  void initAudio() async {
    await AudioPlayer.global.setGlobalAudioContext(const AudioContext(
        iOS: AudioContextIOS(options: [
          AVAudioSessionOptions.allowBluetooth,
          AVAudioSessionOptions.allowBluetoothA2DP,
          AVAudioSessionOptions.allowAirPlay,
          AVAudioSessionOptions.duckOthers,
        ]),
        android: AudioContextAndroid()));
  }

  @override
  Widget build(BuildContext context) {
    initAudio();
    bool displayedHint = false;
    return Column(
      children: [
        Column(
          children: msgs.msgs.map((e) {
            if (e is AIMsgModel) {
              return AiMsgBubble(
                e,
                msgs.scenario.avatar,
                msgs.scenario,
                audioPlayer,
              );
            } else if (e is PersonMsgModel) {
              if (!displayedHint && e.rating != null) {
                displayedHint = true;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    OwnMsgBubble(e),
                    Text(
                      AppLocalizations.of(context)!.chat_page_hint,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.8)),
                    ),
                  ],
                );
              } else {
                return OwnMsgBubble(e);
              }
            } else {
              return Container();
            }
          }).toList(),
        ),
        if (msgs.rating != null)
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              child: GestureDetector(
                child: Text(
                  AppLocalizations.of(context)!.chat_page_end,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      decoration: TextDecoration.underline),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatSummaryPage(
                        msgs.rating!,
                      ),
                    ),
                  );
                },
              ))
      ],
    );
  }
}
