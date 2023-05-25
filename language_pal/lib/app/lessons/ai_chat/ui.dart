import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat_common/components/ai_avatar.dart';
import 'package:poly_app/app/chat_common/components/chat_bubble.dart';
import 'package:poly_app/app/chat_common/components/input_area.dart';
import 'package:poly_app/app/lessons/ai_chat/data.dart';
import 'package:poly_app/app/lessons/ai_chat/logic.dart';
import 'package:poly_app/app/lessons/ai_chat/util.dart';
import 'package:poly_app/app/lessons/common/ui.dart';
import 'package:poly_app/common/logic/languages.dart';
import 'package:poly_app/common/ui/audio_visualizer.dart';
import 'package:poly_app/common/ui/custom_circular_button.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/divider.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';
import 'package:poly_app/common/ui/frosted_effect.dart';
import 'package:poly_app/common/ui/loading_page.dart';
import 'package:poly_app/common/ui/measure_size.dart';
import 'package:poly_app/common/ui/skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  final cont = TextEditingController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeChatSession);
    if (session == null || session.msgs == null) return const LoadingPage();

    Widget bottomWidget = switch (session.status) {
      ChatStatus.waitingForUserRedo => Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: InkWell(
              onTap: () {
                session.status = ChatStatus.waitingForAIResponse;
              },
              borderRadius: BorderRadius.circular(8),
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
            ),
          ),
        ),
      ChatStatus.waitingForAIResponse =>
        AIMsgBubbleLoading(session.lesson.avatar),
      ChatStatus.waitingForConvRating => const AIMsgBubbleLoading("Poly"),
      ChatStatus.finished => Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const AIAvatar("Poly"),
                const SizedBox(width: 4),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Text(session.finalRating!,
                            style: Theme.of(context).textTheme.bodyLarge)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          NextStepWidget(
              nextStepTitle: widget.nextStepTitle,
              onNextStep: widget.onNextStep),
          const SizedBox(height: 128),
        ]),
      _ => const SizedBox(),
    };

    if (session.status == ChatStatus.finished ||
        session.status == ChatStatus.waitingForConvRating) {
      offset = MediaQuery.of(context).padding.bottom;
    }

    return Scaffold(
      appBar: FrostedAppBar(title: Text(session.lesson.name)),
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
                          // TODO: UI Container and width are not matching, ...
                          false => UserMsgBubbleFrame(
                              child: IntrinsicWidth(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          : Text(
                                              e.rating!.type.getTitle(context),
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
                                          e.rating!.type !=
                                              MsgRatingType.correct)
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          height: 1,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                              .withOpacity(0.6),
                                        ),
                                      if (e.rating != null &&
                                          e.rating!.type !=
                                              MsgRatingType.correct)
                                        Text(
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
                                                        .withOpacity(0.6)))
                                    ]),
                              ),
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
          if (session.status != ChatStatus.finished &&
              session.status != ChatStatus.waitingForConvRating)
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
                  child: modeIsAudio
                      ? AudioInput(
                          cont: cont,
                          learnLang: session.learnLang,
                          onSend: (msg) {
                            session.addMsg(UserChatMsg(msg));
                            cont.clear();
                          },
                          onText: () => setState(() {
                                modeIsAudio = false;
                              }),
                          enabled: session.status.allowUserInput,
                          suggestion: session.currentCorrectedVersion)
                      : KeyboardInput(
                          cont: cont,
                          onSend: (msg) {
                            session.addMsg(UserChatMsg(msg));
                            cont.clear();
                          },
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
  final TextEditingController cont;
  const KeyboardInput(
      {required this.onSend,
      required this.cont,
      required this.onAudio,
      required this.suggestion,
      required this.enabled,
      super.key});

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
                controller: cont,
                onSubmitted: (_) => onSend(cont.text),
                hintText:
                    suggestion == null ? "Type here..." : "Try again...")),
        const SizedBox(width: 8),
        SendButton(onPressed: () => onSend(cont.text), enabled: enabled),
      ]),
    );
  }
}

class AudioInput extends StatefulWidget {
  final void Function(String) onSend;
  final void Function() onText;
  final bool enabled;
  final LanguageModel learnLang;
  final TextEditingController cont;
  final ({String appLang, String learnLang})? suggestion;
  const AudioInput(
      {required this.onSend,
      required this.cont,
      required this.onText,
      required this.suggestion,
      required this.enabled,
      required this.learnLang,
      super.key});

  @override
  State<AudioInput> createState() => _AudioInputState();
}

class _AudioInputState extends State<AudioInput> {
  bool listening = false;
  final _speech = SpeechToText();

  @override
  void initState() {
    _initSpeech();
    super.initState();
  }

  void _initSpeech() async {
    final result = await _speech.initialize();
    if (!result) {
      // TODO: Handle not permissions
    }
  }

  void _startListening() async {
    await _speech.listen(
        listenMode: ListenMode.dictation,
        onResult: _onSpeechResult,
        localeId: widget.learnLang.speechRecognitionLocale);
    listening = true;
    setState(() {});
  }

  void _stopListening() async {
    await _speech.stop();
    listening = false;
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      widget.cont.text = result.recognizedWords;
      if (result.finalResult) _stopListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(
                child: ChatTextField(
                    enabled: false,
                    trailing: widget.suggestion == null
                        ? null
                        : CustomCircularButton(
                            outlineColor:
                                Theme.of(context).colorScheme.onBackground,
                            icon:
                                const Icon(CustomIcons.questionmark, size: 18),
                            onPressed: () {
                              showSuggestion(
                                  context,
                                  widget.suggestion!.appLang,
                                  widget.suggestion!.learnLang);
                            },
                            size: 28),
                    controller: widget.cont,
                    onSubmitted: (_) => widget.onSend(widget.cont.text),
                    hintText: widget.suggestion == null
                        ? "Type here..."
                        : "Try again...")),
            const SizedBox(width: 8),
            SendButton(
                onPressed: () => widget.onSend(widget.cont.text),
                enabled: widget.enabled),
          ]),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: AudioVisualizer(const Size(double.infinity, 100), listening),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomLeft,
                child: InkWell(
                    onTap: widget.onText,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                        height: 38,
                        width: 38,
                        child: Icon(CustomIcons.keyboard,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.8),
                            size: 24))),
              ),
            ),
            CustomCircularButton(
                color: Theme.of(context).colorScheme.primary,
                icon: Icon(
                  listening ? CustomIcons.check : CustomIcons.mic,
                  size: 24,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: listening ? _stopListening : _startListening,
                size: 48),
            const Spacer()
          ]),
          const SizedBox(height: 16),
        ],
      ),
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
