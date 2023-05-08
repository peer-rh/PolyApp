import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/lessons/logic/vocab_session.dart';
import 'package:poly_app/app/lessons/ui/components/custom_box.dart';
import 'package:poly_app/app/lessons/ui/input_methods/compose.dart';
import 'package:poly_app/app/lessons/ui/input_methods/selection.dart';
import 'package:poly_app/app/lessons/ui/input_methods/write.dart';
import 'package:poly_app/common/logic/audio_provider.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';
import 'package:poly_app/common/ui/loading_page.dart';

class VocabPage extends ConsumerStatefulWidget {
  final String id;

  const VocabPage(this.id, {super.key});

  @override
  _VocabPageState createState() => _VocabPageState();
}

class _VocabPageState extends ConsumerState<VocabPage> {
  ActiveVocabSession? session;
  int? currentStepIndex;

  void checkAnswer() {
    final session = ref.read(activeVocabSession(widget.id));
    session!.submitAnswer();
    setState(() {});
  }

  @override
  void initState() {
    setState(() {
      currentStep = CurrentStepWidget(widget.id);
    });
    super.initState();
  }

  late Widget currentStep;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeVocabSession(widget.id));
    if (session == null || session.currentStep == null) {
      return const LoadingPage();
    }

    return Scaffold(
        appBar: FrostedAppBar(
          title: Text(session.lesson.title),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                currentStep,
                const Spacer(),
                InkWell(
                  onTap: session.currentStep!.isCorrect != null
                      ? () {
                          session.nextStep();
                        }
                      : session.currentAnswer == ""
                          ? null
                          : () {
                              checkAnswer();
                            },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: session.currentAnswer == "" &&
                                session.currentStep!.isCorrect == null
                            ? Theme.of(context).colorScheme.surfaceVariant
                            : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      session.currentStep!.isCorrect != null ? 'Next' : 'Check',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary),
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
  final String id;
  const CurrentStepWidget(this.id, {super.key});

  @override
  ConsumerState<CurrentStepWidget> createState() => _CurrentStepWidgetState();
}

class _CurrentStepWidgetState extends ConsumerState<CurrentStepWidget> {
  Widget? currentInputWidget;
  Widget? prompt;
  String promptSub = "";

  @override
  void initState() {
    super.initState();
  }

  void playAudio(String path) async {
    final url = await FirebaseStorage.instance.ref(path).getDownloadURL();
    print(url);
    ref.read(audioProvider).playNet(url);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeVocabSession(widget.id));
    if (session == null || session.currentStep == null) {
      return const Text("Loading...");
    }
    switch (session.currentStep!.type) {
      case VocabStepType.select:
      case VocabStepType.write:
      case VocabStepType.compose:
        promptSub = "Translate this phrase";
        prompt = Text(
          session.currentStep!.prompt,
          style: Theme.of(context).textTheme.titleSmall,
        );
        break;
      case VocabStepType.listen:
        promptSub = "Listen to this phrase";
        prompt = FilledButton(
          onPressed: () {
            playAudio(session.currentStep!.audioUrl!);
          },
          child: const Text("Play"),
        );
        break;
      case VocabStepType.pronounce:
        promptSub = "Pronounce this phrase";
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

    switch (session.currentStep!.type) {
      case VocabStepType.select:
      case VocabStepType.listen:
        currentInputWidget = SelectionInput(
          session.currentAnswer,
          session.currentStep!.options!,
          (p0) {
            session.currentAnswer = p0;
          },
          disabled: session.currentStep!.userAnswer != null,
        );
        break;
      case VocabStepType.write:
        currentInputWidget = WriteInput(
          (p0) {
            session.currentAnswer = p0;
          },
          key: ValueKey(session.currentStep!.prompt),
          disabled: session.currentStep!.userAnswer != null,
        );
        break;
      case VocabStepType.compose:
        currentInputWidget = ComposeInput(
          session.currentStep!.options!,
          (p0) {
            session.currentAnswer = p0;
          },
          key: ValueKey(session.currentStep!.prompt),
          disabled: session.currentStep!.userAnswer != null,
        );
        break;
      default:
        currentInputWidget = FilledButton(
            onPressed: () {
              session.nextStep();
            },
            child: const Text("Next"));
    }
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
              ],
            )),
        const SizedBox(height: 32),
        currentInputWidget!,
        if (session.currentStep!.isCorrect != null) const SizedBox(height: 16),
        if (session.currentStep!.isCorrect != null)
          CustomBox(
            backgroundColor: session.currentStep!.isCorrect!
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            child: Text(
              session.currentStep!.isCorrect!
                  ? 'Correct!'
                  : 'Incorrect: ${session.currentStep!.answer}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
      ],
    );
  }
}