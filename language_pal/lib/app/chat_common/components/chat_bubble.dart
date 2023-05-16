import 'package:flutter/material.dart';
import 'package:poly_app/app/chat_common/components/ai_avatar.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/loading_three_dots.dart';

class UserMsgBubbleFrame extends StatelessWidget {
  final Widget child;
  const UserMsgBubbleFrame({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: child),
          ),
        ),
      ],
    );
  }
}

class AiMsgBubbleFrame extends StatelessWidget {
  final Widget child;
  final AIAvatar avatar;
  const AiMsgBubbleFrame(
      {required this.child, required this.avatar, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        avatar,
        const SizedBox(width: 4),
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: child),
          ),
        ),
      ],
    );
  }
}

class AIMsgBubble extends StatefulWidget {
  final String msg;
  final Future<void> Function() onPlayAudio;
  final Future<void> Function() onTranslate;
  final String avatar;
  const AIMsgBubble(
      {required this.msg,
      required this.onPlayAudio,
      required this.onTranslate,
      required this.avatar,
      super.key});

  @override
  State<AIMsgBubble> createState() => _AIMsgBubbleState();
}

class _AIMsgBubbleState extends State<AIMsgBubble> {
  bool _loadingAudio = false;
  bool _loadingTranslation = false;
  @override
  Widget build(BuildContext context) {
    return AiMsgBubbleFrame(
      avatar: AIAvatar(widget.avatar),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.msg,
              textWidthBasis: TextWidthBasis.longestLine,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                color: Theme.of(context).colorScheme.onSurface,
                onPressed: () async {
                  setState(() {
                    _loadingAudio = true;
                  });
                  await widget.onPlayAudio();
                  setState(() {
                    _loadingAudio = false;
                  });
                },
                icon: _loadingAudio
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(),
                      )
                    : const Icon(CustomIcons.volume, size: 18),
              ),
              IconButton(
                color: Theme.of(context).colorScheme.onSurface,
                onPressed: () async {
                  setState(() {
                    _loadingTranslation = true;
                  });
                  await widget.onTranslate();
                  setState(() {
                    _loadingTranslation = false;
                  });
                },
                icon: _loadingTranslation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(),
                      )
                    : const Icon(Icons.translate, size: 18),
              ),
            ])
          ]),
    );
  }
}

class AIMsgBubbleLoading extends StatelessWidget {
  final String avatar;
  const AIMsgBubbleLoading(this.avatar, {super.key});

  @override
  Widget build(BuildContext context) {
    return AiMsgBubbleFrame(
      avatar: AIAvatar(avatar),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child:
              LoadingThreeDots(color: Theme.of(context).colorScheme.onSurface)),
    );
  }
}
