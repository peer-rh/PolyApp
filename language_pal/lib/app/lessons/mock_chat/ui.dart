import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat_common/components/chat_bubble.dart';
import 'package:poly_app/app/lessons/common/input/data.dart';
import 'package:poly_app/app/lessons/common/input/ui.dart';
import 'package:poly_app/app/lessons/common/ui.dart';
import 'package:poly_app/app/lessons/mock_chat/logic.dart';
import 'package:poly_app/common/logic/audio_provider.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/divider.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';
import 'package:poly_app/common/ui/frosted_effect.dart';
import 'package:poly_app/common/ui/loading_page.dart';
import 'package:poly_app/common/ui/measure_size.dart';

class MockChatPage extends ConsumerStatefulWidget {
  final void Function() onFinished;
  final void Function(BuildContext context) onNextStep;
  final String nextStepTitle;
  const MockChatPage(
      {required this.onFinished,
      required this.nextStepTitle,
      required this.onNextStep,
      Key? key})
      : super(key: key);

  @override
  _MockChatPageState createState() => _MockChatPageState();
}

class _MockChatPageState extends ConsumerState<MockChatPage> {
  double offset = 0;
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeMockChatSession);
    if (session == null || (session.currentStep == null && !session.finished)) {
      return const LoadingPage();
    }

    return Scaffold(
      appBar: FrostedAppBar(
        title: Text(session.lesson.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              ListView(
                  controller: _scrollController,
                  reverse: true,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  children: [
                    ...session.pastConv.map((e) => switch (e.isAi) {
                          true => AIMsgBubble(
                              msg: e.learnLang,
                              onPlayAudio: () async {
                                ref.read(cachedVoiceProvider).play(e.audioUrl);
                              },
                              onTranslate: () async {
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                            title: const Text('Translation'),
                                            content: Text(e.appLang),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Close'))
                                            ]));
                              },
                              avatar: session.lesson.avatar),
                          false => UserMsgBubbleFrame(
                              child: Text(
                                e.learnLang,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                              ),
                            ),
                        }),
                    if (session.pastConv.isEmpty)
                      const Text("Select a fitting starting message"),
                    if (session.finished)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          const CustomDivider(text: "Finished Conversation"),
                          const SizedBox(height: 16),
                          NextStepWidget(
                              nextStepTitle: widget.nextStepTitle,
                              onNextStep: widget.onNextStep),
                          const SizedBox(height: 96),
                        ],
                      ),
                    SizedBox(height: offset),
                  ].reversed.toList()),
              if (!session.finished)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: MeasureSize(
                    onChange: (size) {
                      if (size.height == offset) return;
                      setState(() {
                        offset = size.height;
                      });
                    },
                    child: FrostedEffect(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (session.currentStep!.type == InputType.pronounce)
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                session.currentStep!.prompt,
                              )),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: MockChatInputWidget(
                            step: session.currentStep!,
                            onChange: (value) {
                              session.currentAnswer = value;
                            },
                            onSubmit: session.submitAnswer,
                            onSkip: () {
                              session.currentAnswer = '';
                              session.submitAnswer();
                            },
                            currentAnswer: session.currentAnswer,
                          ),
                        ),
                      ],
                    )),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
