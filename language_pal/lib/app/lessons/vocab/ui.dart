import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat_common/components/ai_avatar.dart';
import 'package:poly_app/app/lessons/common/input/data.dart';
import 'package:poly_app/app/lessons/common/input/ui.dart';
import 'package:poly_app/app/lessons/common/ui.dart';
import 'package:poly_app/app/lessons/vocab/logic.dart';
import 'package:poly_app/common/logic/abilities.dart';
import 'package:poly_app/common/logic/audio_provider.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
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
  _VocabPageState createState() => _VocabPageState();
}

class _VocabPageState extends ConsumerState<VocabPage> {
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

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeVocabSession);
    if (session == null || (session.currentStep == null && !session.finished)) {
      return const LoadingPage();
    }

    if (session.finished) {
      widget.onFinished();
    }

    return Scaffold(
        appBar: FrostedAppBar(
          title: Text(session.lesson.title),
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
                        "You've just completed \"${session.lesson.title}\"",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 64),
                      // TODO: Review Errors
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
  Widget? currentInputWidget;
  Widget? prompt;
  String promptSub = "";
  Widget? disableButton;

  @override
  void initState() {
    super.initState();
  }

  void playAudio(String path) async {
    ref.read(cachedVoiceProvider).play(path);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeVocabSession);
    if (session == null || session.currentStep == null) {
      return const Text("Loading...");
    }
    switch (session.currentStep!.type) {
      case InputType.select:
      case InputType.write:
      case InputType.compose:
        disableButton = null;
        promptSub = "Translate this phrase";
        prompt = Text(
          session.currentStep!.prompt,
          style: Theme.of(context).textTheme.titleSmall,
        );
        break;
      case InputType.listen:
        disableButton = TextButton(
            onPressed: () {
              customAlert(
                  context: context,
                  title: "Can't listen",
                  content:
                      "This will disable all listening exercises for the next 15 minutes",
                  onConfirm: () {
                    ref.read(cantListenProvider.notifier).setOn();
                  });
            },
            child: Text(
              "I can't listen right now",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ));
        promptSub = "Listen to this phrase";
        prompt = GestureDetector(
          onTap: () {
            playAudio(session.currentStep!.audioUrl!);
          },
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary,
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(CustomIcons.volume,
                    size: 24, color: Theme.of(context).colorScheme.onPrimary),
                const SizedBox(width: 8),
                Text(
                  "Listen",
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                )
              ])),
        );
        break;
      case InputType.pronounce:
        promptSub = "Pronounce this phrase";
        disableButton = TextButton(
            onPressed: () {
              customAlert(
                  context: context,
                  title: "Can't talk",
                  content:
                      "This will disable all pronunciation exercises for the next 15 minutes",
                  onConfirm: () {
                    ref.read(cantTalkProvider.notifier).setOn();
                  });
            },
            child: Text(
              "I can't talk right now",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ));
        prompt = Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  playAudio(session.currentStep!.audioUrl!);
                },
                icon: Icon(CustomIcons.volume,
                    color: Theme.of(context).colorScheme.onSurface),
                iconSize: 36,
              ),
              const SizedBox(width: 4),
              Text(session.currentStep!.prompt,
                  style: Theme.of(context).textTheme.titleSmall),
            ]);
        break;
    }
    currentInputWidget = VocabInputWidget(
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
    );

    setState(() {});

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomBox(
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promptSub,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                prompt!,
                disableButton ?? const SizedBox()
              ],
            )),
        const SizedBox(height: 32),
        currentInputWidget!,
      ],
    );
  }

  void customAlert(
      {required BuildContext context,
      required String title,
      required String content,
      required void Function() onConfirm}) {
    Widget cancelButton = TextButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        )),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text("Cancel"),
    );
    Widget continueButton = FilledButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        )),
      ),
      child: const Text("Confirm"),
      onPressed: () {
        onConfirm();
        Navigator.of(context).pop();
      },
    );

    // Create the dialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: Text(title),
      content: Text(content),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }
}
