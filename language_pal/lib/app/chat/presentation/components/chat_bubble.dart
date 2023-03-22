import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:language_pal/app/chat/logic/translation.dart';
import 'package:language_pal/app/chat/logic/tts_gcp.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:provider/provider.dart';

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
                          child: const Text("Close"))
                    ],
                  ));
        },
        child: Text(
          msg.rating!.short,
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
    return Align(
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
  final AIMsgModel msg;
  final String avatar;
  AiMsgBubble(this.msg, this.avatar, {super.key});

  showTranslation(BuildContext context, String translation) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Translation"),
            content: Text(translation),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.asset(
            avatar,
            width: 40,
            height: 40,
          ),
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
                        IconButton(
                          onPressed: () {
                            String lang =
                                context.read<AuthProvider>().user!.learnLang;
                            getTranslations(msg.msg, lang).then((translations) {
                              msg.translations = translations;
                              showTranslation(context, translations);
                            });
                          },
                          icon: const Icon(Icons.translate, size: 18),
                        ),
                        IconButton(
                          onPressed: () async {
                            // BUG: Does not play
                            AudioPlayer audioPlayer = AudioPlayer();
                            await audioPlayer.setVolume(1.0);
                            await audioPlayer.play(BytesSource(
                                await generateTextToSpeech(msg.msg)));
                            print(audioPlayer.state);
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
