import 'package:flutter/material.dart';
import 'package:poly_app/app/chat_common/components/ai_avatar.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/loading_three_dots.dart';

class UserMsgBubbleFrame extends StatelessWidget {
  final Widget child;
  final Color? color;
  const UserMsgBubbleFrame({required this.child, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color ?? Theme.of(context).colorScheme.primary,
              ),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: child),
            ),
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          avatar,
          const SizedBox(width: 4),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
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
      ),
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
            const SizedBox(height: 4),
            Material(
              color: Colors.transparent,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _loadingAudio
                      ? null
                      : () async {
                          setState(() {
                            _loadingAudio = true;
                          });
                          await widget.onPlayAudio();
                          setState(() {
                            _loadingAudio = false;
                          });
                        },
                  child: Container(
                    alignment: Alignment.center,
                    width: 32,
                    height: 32,
                    child: _loadingAudio
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onSurface,
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(CustomIcons.volume,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _loadingTranslation
                      ? null
                      : () async {
                          setState(() {
                            _loadingTranslation = true;
                          });
                          await widget.onTranslate();
                          setState(() {
                            _loadingTranslation = false;
                          });
                        },
                  child: Container(
                    alignment: Alignment.center,
                    width: 32,
                    height: 32,
                    child: _loadingTranslation
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onSurface,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.translate, size: 18),
                  ),
                ),
              ]),
            )
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
