import 'dart:math' as math show sin, pi;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/logic/rating.dart';
import 'package:language_pal/app/chat/logic/translation.dart';
import 'package:language_pal/app/chat/logic/tts_gcp.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/chat/presentation/components/ai_avatar.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';

class SingularOwnMsgBubble extends StatelessWidget {
  final SingularPersonMsgModel msg;
  const SingularOwnMsgBubble(this.msg, {super.key});

  Widget rating(BuildContext context) {
    if (msg.rating != null) {
      return Text(
        generateRatingShort(context, msg.rating!.type),
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
        ),
      );
    }
    return const SkeletonRating();
  }

  Widget ratingSuggestion(BuildContext context) {
    if (msg.rating != null &&
        msg.rating!.suggestion != null &&
        msg.rating!.type != MsgRatingType.correct) {
      return Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              width: 0.5,
            ),
          ),
        ),
        child: Text(
          msg.rating!.suggestionTranslated ?? msg.rating!.suggestion!,
          textWidthBasis: TextWidthBasis.longestLine,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1),
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primary,
          margin: const EdgeInsets.all(0),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!msg.suggested) rating(context),
                Text(
                  msg.msg,
                  textWidthBasis: TextWidthBasis.longestLine,
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
                if (msg.rating != null) ratingSuggestion(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OwnMsgBubble extends StatelessWidget {
  PersonMsgModel msg;
  OwnMsgBubble(this.msg, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var m in msg.msgs) SingularOwnMsgBubble(m),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
                      ? const AnimatedThinking()
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
    super.initState();
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
              size: const Size.square(12),
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

class SkeletonRating extends StatefulWidget {
  const SkeletonRating({super.key});

  @override
  State<SkeletonRating> createState() => _SkeletonRatingState();
}

class _SkeletonRatingState extends State<SkeletonRating>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation gradientPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);

    gradientPosition = Tween<double>(
      begin: -3,
      end: 10,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    )..addListener(() {
        setState(() {});
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 14,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
              begin: Alignment(gradientPosition.value, 0),
              end: const Alignment(-1, 0),
              colors: [
                Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
              ])),
    );
  }
}
