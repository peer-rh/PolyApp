import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat_common/components/ai_avatar.dart';
import 'package:poly_app/app/lessons/common/input/ui.dart';
import 'package:poly_app/app/lessons/common/ui.dart';
import 'package:poly_app/app/lessons/vocab/logic.dart';
import 'package:poly_app/app/lessons/vocab/vocab_prompt.dart';
import 'package:poly_app/app/smart_review/logic/spaced_review.dart';
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

  @override
  void initState() {
    setState(() {
      currentStep = const CurrentStepWidget();
    });
    super.initState();
  }

  late Widget currentStep;
  bool alreadyFinished =
      true; // Init to true, so that first startup when finished doesn't save

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeVocabSession);
    if (session == null || (session.currentStep == null && !session.finished)) {
      return const LoadingPage();
    }

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
                            "Poly",
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
                      const Spacer(),
                      currentStep, // TODO: Done UI
                      const Spacer(),
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
  const CurrentStepWidget({super.key});

  @override
  ConsumerState<CurrentStepWidget> createState() => _CurrentStepWidgetState();
}

class _CurrentStepWidgetState extends ConsumerState<CurrentStepWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeVocabSession);
    if (session == null || session.currentStep == null) {
      return const Text("Loading...");
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VocabPrompt(step: session.currentStep!),
        const SizedBox(height: 32),
        VocabInputWidget(
          step: session.currentStep!,
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
