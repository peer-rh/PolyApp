import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/data/messages.dart';
import 'package:language_pal/app/chat/data/user_msg_rating_model.dart';
import 'package:language_pal/app/chat/features/text2speech.dart';
import 'package:language_pal/app/chat/features/translation.dart';
import 'package:language_pal/app/chat/ui/components/ai_avatar.dart';
import 'package:language_pal/common/data/scenario_model.dart';
import 'package:language_pal/common/ui/loading_three_dots.dart';
import 'package:language_pal/common/ui/skeleton.dart';

class SingularOwnMsgBubble extends StatelessWidget {
  final SingularPersonMsgModel msg;
  const SingularOwnMsgBubble(this.msg, {super.key});

  Widget rating(BuildContext context) {
    if (msg.rating != null) {
      return Text(
        msg.rating!.type.getTitle(context),
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
        ),
      );
    }
    return SizedBox(
        height: 14,
        width: 100,
        child: SkeletonBox(color: Theme.of(context).colorScheme.onPrimary));
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
    return MessageBubble(
      color: Theme.of(context).colorScheme.primary,
      left: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.suggested) rating(context),
          Text(
            msg.msg,
            textWidthBasis: TextWidthBasis.longestLine,
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
          ),
          if (msg.rating != null) ratingSuggestion(context),
        ],
      ),
    );
  }
}

class OwnMsgBubble extends StatelessWidget {
  final PersonMsgListModel msg;
  const OwnMsgBubble(this.msg, {super.key});

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
  final AudioPlayer audioPlayer;
  final String avatar;
  const AiMsgBubble(this.msg, this.avatar, this.scenario, this.audioPlayer,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return MessageBubble(
      color: Theme.of(context).colorScheme.surfaceVariant,
      left: true,
      preIcon: AIAvatar(avatar),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            msg.msg,
            textWidthBasis: TextWidthBasis.longestLine,
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [
            TranslationButton(msg),
            TTSButton(msg, audioPlayer, scenario),
          ])
        ],
      ),
    );
  }
}

class AIMsgBubbleLoading extends StatelessWidget {
  final String avatar;
  const AIMsgBubbleLoading(this.avatar, {super.key});

  @override
  Widget build(BuildContext context) {
    return MessageBubble(
        color: Theme.of(context).colorScheme.surfaceVariant,
        left: true,
        preIcon: AIAvatar(avatar),
        child: LoadingThreeDots(
            color: Theme.of(context).colorScheme.onSurfaceVariant));
  }
}

class MessageBubble extends StatelessWidget {
  final Color color;
  final Widget child;
  final bool left;
  final Widget? preIcon;
  const MessageBubble(
      {required this.color,
      required this.left,
      this.preIcon,
      required this.child,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          preIcon ?? const SizedBox(),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              elevation: 0,
              color: color,
              child: Padding(padding: const EdgeInsets.all(10), child: child),
            ),
          ),
        ],
      ),
    );
  }
}
