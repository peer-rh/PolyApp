import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat/ui/components/chat_bubble.dart';
import 'package:poly_app/app/learn_track/data/status.dart';
import 'package:poly_app/app/learn_track/logic/user_progress_provider.dart';
import 'package:poly_app/app/lessons/data/input_step.dart';
import 'package:poly_app/app/lessons/logic/mock_chat_session.dart';
import 'package:poly_app/app/lessons/ui/input_methods/lib.dart';
import 'package:poly_app/common/logic/audio_provider.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';
import 'package:poly_app/common/ui/frosted_effect.dart';
import 'package:poly_app/common/ui/loading_page.dart';
import 'package:poly_app/common/ui/measure_size.dart';

class MockChatPage extends ConsumerStatefulWidget {
  const MockChatPage({Key? key}) : super(key: key);

  @override
  _MockChatPageState createState() => _MockChatPageState();
}

class _MockChatPageState extends ConsumerState {
  double offset = 0;
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  Widget build(BuildContext context) {
    final id = ref.read(activeMockChatId)!;
    if (ref.read(userProgressProvider).getStatus(id) ==
        UserProgressStatus.notStarted) {
      ref
          .read(userProgressProvider)
          .setStatus(id, UserProgressStatus.inProgress);
    }

    final session = ref.watch(activeMockChatSession);
    if (session == null || (session.currentStep == null && !session.finished)) {
      return const LoadingPage();
    }

    if (session.finished) {
      Future(() {
        ref
            .read(userProgressProvider)
            .setStatus(id, UserProgressStatus.completed);
      });
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
                    SizedBox(height: offset),
                  ].reversed.toList()),
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
