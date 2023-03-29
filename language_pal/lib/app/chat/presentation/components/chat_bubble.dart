import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:language_pal/app/chat/logic/rating.dart';
import 'package:language_pal/app/chat/logic/translation.dart';
import 'package:language_pal/app/chat/logic/tts_gcp.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/chat/presentation/components/ai_avatar.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OwnMsgBubble extends StatelessWidget {
  final PersonMsgModel msg;
  const OwnMsgBubble(this.msg, {super.key});

  Widget rating(BuildContext context) {
    if (msg.rating != null) {
      return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    content: Text(msg.rating!.details),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.close))
                    ],
                  ));
        },
        child: Text(
          generateRatingShort(context, msg.rating!.type),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
          ),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: GestureDetector(
          onLongPress: () {
            // TODO: Option to edit
          },
          child: Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.rating != null) rating(context),
                  Text(
                    msg.msg,
                    textWidthBasis: TextWidthBasis.longestLine,
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AiMsgBubble extends StatelessWidget {
  final ScenarioModel scenario;
  final AIMsgModel msg;
  AudioPlayer audioPlayer = AudioPlayer();
  final String avatar;
  AiMsgBubble(this.msg, this.avatar, this.scenario, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AIAvatar(avatar),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            child: GestureDetector(
              onLongPress: () {
                // TODO: Menu for Report
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.msg,
                        textWidthBasis: TextWidthBasis.longestLine,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        TranslationButton(msg),
                        IconButton(
                          onPressed: () async {
                            msg.audioPath = msg.audioPath ??
                                await generateTextToSpeech(msg.msg, scenario);
                            await AudioPlayer.global
                                .setGlobalAudioContext(const AudioContext(
                                    iOS: AudioContextIOS(options: [
                                      AVAudioSessionOptions.allowBluetooth,
                                      AVAudioSessionOptions.allowBluetoothA2DP,
                                      AVAudioSessionOptions.allowAirPlay,
                                      AVAudioSessionOptions.duckOthers,
                                    ]),
                                    android: AudioContextAndroid()));
                            await audioPlayer
                                .play(DeviceFileSource(msg.audioPath!));
                          },
                          icon:
                              const Icon(FontAwesomeIcons.volumeHigh, size: 18),
                        ),
                      ])
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
