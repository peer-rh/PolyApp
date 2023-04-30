import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:poly_app/app/chat/data/conversation.dart';
import 'package:poly_app/app/chat/data/messages.dart';
import 'package:poly_app/app/chat/ui/chat_summary_page.dart';
import 'package:poly_app/app/chat/ui/components/ai_avatar.dart';
import 'package:poly_app/app/chat/ui/components/chat_bubble.dart';
import 'package:poly_app/common/data/scenario_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConversationColumn extends StatelessWidget {
  AudioPlayer audioPlayer = AudioPlayer();
  Conversation conv;
  Map<String, dynamic>? audioInfo;
  bool translationEnabled;
  String aiAvatar;
  ConversationColumn({
    super.key,
    required this.conv,
    this.translationEnabled = false,
    this.audioInfo,
    required this.aiAvatar,
  });

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
          children: conv.msgs.map((e) {
            if (e is AIMsgModel) {
              return AiMsgBubble(
                e,
                aiAvatar,
                audioInfo,
                audioPlayer,
                translationEnabled: translationEnabled,
              );
            } else if (e is PersonMsgListModel) {
              return OwnMsgBubble(e);
            } else {
              return const SizedBox(
                height: 0,
                width: 0,
              );
            }
          }).toList(),
        ),
        if (conv.rating != null)
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 15, bottom: 10),
            child: GestureDetector(
              child: Text(
                AppLocalizations.of(context)!.chat_page_end,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    decoration: TextDecoration.underline),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatSummaryPage(
                      conv.rating!,
                    ),
                  ),
                );
              },
            ),
          )
      ],
    );
  }
}
