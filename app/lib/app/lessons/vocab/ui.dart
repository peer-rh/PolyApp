import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat_common/components/ai_avatar.dart';
import 'package:poly_app/app/lessons/common/input/ui.dart';
import 'package:poly_app/app/lessons/common/ui.dart';
import 'package:poly_app/app/lessons/vocab/logic.dart';
import 'package:poly_app/app/lessons/vocab/vocab_prompt.dart';
import 'package:poly_app/app/smart_review/logic/spaced_review.dart';
import 'package:poly_app/common/logic/audio_provider.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';
import 'package:poly_app/common/ui/loading_page.dart';

class VocabPage extends ConsumerStatefulWidget {
  final void Function() onFinished;
  final String nextStepTitle;
  final void Function(BuildContext) onNextStep;
  const VocabPage(
      {required this.onFinished,
      required this.nextStepTitle,
      required this.onNextStep,
      super.key});

  @override
  VocabPageState createState() => VocabPageState();
}

class VocabPageState extends ConsumerState<VocabPage> {
  ActiveVocabSession? session;
  int? currentStepIndex;

  void checkAnswer() {
    final session = ref.read(activeVocabSession);
    session!.submitAnswer();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  late Widget currentStep;
  bool alreadyFinished =
      true; // Init to true, so that first startup when finished doesn't save

  final PageController _pageCont = PageController();

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeVocabSession);
    if (session == null || (session.currentStep == null && !session.finished)) {
      return const LoadingPage();
    }

    if (_pageCont.hasClients) {
      _pageCont.animateToPage(session.currentStepIndex,
          duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
    }
    Future(() {
      ref.read(useCachedVoice.notifier).state = !session.lesson.isCustom;
    });

    if (session.finished && !alreadyFinished) {
      widget.onFinished();
      Future(() =>
          ref.read(spacedReviewProvider).addItems(session.lesson.vocabList));
      alreadyFinished = true;
    } else {
      alreadyFinished =
          false; // NOTE: Kinda shitty to check whether we've already finished
    }

    return Scaffold(
        appBar: FrostedAppBar(
          title: Text(session.lesson.name),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: session.finished
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                          alignment: Alignment.center,
                          child: AIAvatar(
                            "poly",
                            radius: 64,
                          )),
                      const SizedBox(height: 16),
                      Text(
                        "Congratulations!",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Text(
                        "You've just completed \"${session.lesson.name}\"",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 64),
                      NextStepWidget(
                          nextStepTitle: widget.nextStepTitle,
                          onNextStep: widget.onNextStep)
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: PageView.builder(
                          itemCount: session.steps.length,
                          controller: _pageCont,
                          itemBuilder: (context, idx) {
                            return Center(child: CurrentStepWidget(idx));
                          },
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                      ),
                      InkWell(
                        onTap: session.currentStep!.isCorrect != null
                            ? session.nextStep
                            : session.currentAnswer == ""
                                ? null
                                : checkAnswer,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: session.currentAnswer == "" &&
                                      session.currentStep?.isCorrect == null
                                  ? Theme.of(context).colorScheme.surfaceVariant
                                  : Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            session.currentStep!.isCorrect != null
                                ? 'Next'
                                : 'Check',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ));
  }
}

class CurrentStepWidget extends ConsumerStatefulWidget {
  const CurrentStepWidget(this.idx, {super.key});
  final int idx;

  @override
  ConsumerState<CurrentStepWidget> createState() => _CurrentStepWidgetState();
}

class _CurrentStepWidgetState extends ConsumerState<CurrentStepWidget> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeVocabSession);
    if (session == null || session.currentStep == null) {
      return const Text("Loading...");
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VocabPrompt(step: session.steps[widget.idx]),
        const SizedBox(height: 32),
        VocabInputWidget(
          step: session.steps[widget.idx],
          onChange: (String ans) {
            session.currentAnswer = ans;
          },
          onSubmit: session.submitAnswer,
          onSkip: () {
            session.currentAnswer = "";
            session.submitAnswer();
            session.nextStep();
          },
          currentAnswer: session.currentAnswer,
          key: Key(session.currentStep!.answer),
        )
      ],
    );
  }
}
