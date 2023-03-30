import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/chat/presentation/chat_summary_page.dart';
import 'package:language_pal/app/chat/presentation/components/chat_bubble.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatBubbleColumn extends StatelessWidget {
  AudioPlayer audioPlayer = AudioPlayer();
  void Function()? sendAnyways;
  ChatBubbleColumn({
    super.key,
    required this.msgs,
    this.sendAnyways,
  });

  final Conversation msgs;

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
              return OwnMsgBubble(e);
            } else {
              return Container();
            }
          }).toList(),
        ),
        if (sendAnyways != null)
          Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: sendAnyways,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.reply, size: 14),
                      const SizedBox(width: 6),
                      Text(AppLocalizations.of(context)!.chat_page_send_anyways,
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              )),
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
