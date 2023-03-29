import 'dart:math' as math show sin, pi;

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
  AudioPlayer audioPlayer;
  final String avatar;
  AiMsgBubble(this.msg, this.avatar, this.scenario, this.audioPlayer,
      {super.key});

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
                  child: !msg.loaded
                      ? AnimatedThinking()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.msg,
                              textWidthBasis: TextWidthBasis.longestLine,
                              style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                            ),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              TranslationButton(msg),
                              TTSButton(msg, audioPlayer, scenario),
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

class AnimatedThinking extends StatefulWidget {
  const AnimatedThinking({super.key});

  @override
  State<AnimatedThinking> createState() => _AnimatedThinkingState();
}

class _AnimatedThinkingState extends State<AnimatedThinking>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.addListener(() {
      setState(() {});
    });
    _controller.repeat();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return ScaleTransition(
          scale: DelayTween(begin: 0.0, end: 1.0, delay: i * .2)
              .animate(_controller),
          child: SizedBox.fromSize(
              size: Size.square(14),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      shape: BoxShape.circle))),
        );
      }),
    );
  }
}

class DelayTween extends Tween<double> {
  DelayTween({double? begin, double? end, required this.delay})
      : super(begin: begin, end: end);

  final double delay;

  @override
  double lerp(double t) =>
      super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}
