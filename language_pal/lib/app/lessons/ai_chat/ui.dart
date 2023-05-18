import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat_common/components/ai_avatar.dart';
import 'package:poly_app/app/chat_common/components/chat_bubble.dart';
import 'package:poly_app/app/chat_common/components/input_area.dart';
import 'package:poly_app/app/lessons/ai_chat/data.dart';
import 'package:poly_app/app/lessons/ai_chat/logic.dart';
import 'package:poly_app/app/lessons/ai_chat/util.dart';
import 'package:poly_app/app/lessons/common/ui.dart';
import 'package:poly_app/common/ui/custom_circular_button.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/divider.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';
import 'package:poly_app/common/ui/frosted_effect.dart';
import 'package:poly_app/common/ui/loading_page.dart';
import 'package:poly_app/common/ui/measure_size.dart';
import 'package:poly_app/common/ui/skeleton.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String nextStepTitle;
  final void Function() onFinished;
  final void Function(BuildContext) onNextStep;
  const ChatPage(
      {required this.onFinished,
      required this.onNextStep,
      required this.nextStepTitle,
      super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  bool modeIsAudio = false;
  double offset = 0;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeChatSession);
    if (session == null || session.msgs == null) return const LoadingPage();

    Widget bottomWidget = switch (session.status) {
      ChatStatus.waitingForUserRedo => Align(
          alignment: Alignment.topRight,
          child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
            ),
            onPressed: () {
              session.status = ChatStatus.waitingForAIResponse;
            },
            child: const Text(
              'Send Anyways',
            ),
          ),
        ),
      ChatStatus.waitingForAIResponse =>
        AIMsgBubbleLoading(session.lesson.avatar),
      ChatStatus.waitingForConvRating => const AIMsgBubbleLoading("Poly"),
      ChatStatus.finished => Column(mainAxisSize: MainAxisSize.min, children: [
          AiMsgBubbleFrame(
              avatar: const AIAvatar("Poly"),
              child: Text(session.finalRating!,
                  style: Theme.of(context).textTheme.bodyLarge)),
          const SizedBox(height: 16),
          NextStepWidget(
              nextStepTitle: widget.nextStepTitle,
              onNextStep: widget.onNextStep)
        ]),
      _ => const SizedBox(),
    };
    return Scaffold(
      appBar: FrostedAppBar(title: Text(session.lesson.title)),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              reverse: true,
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: [
                ...session.msgs!
                    .map((e) => switch (e.isAi) {
                          true => AIMsgBubble(
                              avatar: session.lesson.avatar,
                              msg: e.msg,
                              onPlayAudio: () async {
                                await ref
                                    .read(ttsProvider)
                                    .speak(session.lesson.voiceSettings, e.msg);
                              },
                              onTranslate: () async {
                                final trans = await ref
                                    .read(translationProvider)
                                    .translate(e.msg);
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Translation'),
                                      content: Text(trans),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'))
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          false => UserMsgBubbleFrame(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    (e as UserChatMsg).rating == null
                                        ? SizedBox(
                                            height: 16,
                                            width: 100,
                                            child: SkeletonBox(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                          )
                                        : Text(e.rating!.type.getTitle(context),
                                            textWidthBasis:
                                                TextWidthBasis.longestLine,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                        .withOpacity(0.8))),
                                    Text(e.msg,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary)),
                                    if (e.rating != null &&
                                        e.rating!.type != MsgRatingType.correct)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary
                                                      .withOpacity(0.6),
                                                  width: 1)),
                                        ),
                                        child: Text(
                                            e.rating!.suggestion ??
                                                "Something went wrong",
                                            textWidthBasis:
                                                TextWidthBasis.longestLine,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                        .withOpacity(0.6))),
                                      )
                                  ]),
                            ),
                        })
                    .toList(),
                if (session.status == ChatStatus.finished ||
                    session.status == ChatStatus.waitingForConvRating)
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CustomDivider(text: "End of Conversation")),
                bottomWidget,
                SizedBox(height: offset),
              ].reversed.toList()),
          MeasureSize(
            onChange: (size) {
              setState(() {
                offset = size.height;
              });
            },
            child: FrostedEffect(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                child: KeyboardInput(
                  onSend: (msg) => session.addMsg(UserChatMsg(msg)),
                  onAudio: () => setState(() {
                    modeIsAudio = true;
                  }),
                  suggestion: session.currentCorrectedVersion,
                  enabled: session.status.allowUserInput,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class KeyboardInput extends StatelessWidget {
  final void Function(String) onSend;
  final void Function() onAudio;
  final bool enabled;
  final ({String appLang, String learnLang})? suggestion;
  KeyboardInput(
      {required this.onSend,
      required this.onAudio,
      required this.suggestion,
      required this.enabled,
      super.key});

  final _cont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        InkWell(
            onTap: onAudio,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
                height: 38,
                width: 38,
                child: Icon(CustomIcons.chataudio,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.8),
                    size: 24))),
        const SizedBox(width: 8),
        Expanded(
            child: ChatTextField(
                trailing: suggestion == null
                    ? null
                    : CustomCircularButton(
                        outlineColor:
                            Theme.of(context).colorScheme.onBackground,
                        icon: const Icon(CustomIcons.questionmark, size: 18),
                        onPressed: () {
                          showSuggestion(context, suggestion!.appLang,
                              suggestion!.learnLang);
                        },
                        size: 28),
                controller: _cont,
                onSubmitted: (_) => onSend(_cont.text),
                hintText:
                    suggestion == null ? "Type here..." : "Try again...")),
        const SizedBox(width: 8),
        SendButton(onPressed: () => onSend(_cont.text), enabled: enabled),
      ]),
    );
  }
}

void showSuggestion(BuildContext context, String appLang, String learnLang) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text("Suggestion"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(learnLang, style: Theme.of(context).textTheme.bodyLarge),
            const Divider(),
            Text(appLang, style: Theme.of(context).textTheme.bodyMedium)
          ],
        )),
  );
}
