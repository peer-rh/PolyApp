import 'package:flutter/material.dart';
import 'package:poly_app/app/lessons/common/input/data.dart';
import 'package:poly_app/app/lessons/common/input/widgets/compose.dart';
import 'package:poly_app/app/lessons/common/input/widgets/pronounce.dart';
import 'package:poly_app/app/lessons/common/input/widgets/selection.dart';
import 'package:poly_app/app/lessons/common/input/widgets/write.dart';
import 'package:poly_app/app/lessons/common/ui.dart';

class VocabInputWidget extends StatelessWidget {
  final InputStep step;
  final void Function(String) onChange;
  final String currentAnswer;
  final void Function() onSubmit;
  final void Function() onSkip;
  const VocabInputWidget(
      {required this.step,
      required this.onChange,
      required this.currentAnswer,
      required this.onSubmit,
      required this.onSkip,
      super.key});

  @override
  Widget build(BuildContext context) {
    bool finished = step.userAnswer != null;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      switch (step.type) {
        InputType.write => WriteInput(onChange, finished),
        InputType.select || InputType.listen => SelectionInput(
            currentAnswer, step.options!, onChange,
            disabled: finished, correctAnswer: finished ? step.answer : null),
        InputType.compose =>
          ComposeInput(step.options!, onChange, disabled: finished),
        InputType.pronounce => PronounciationInput(
            onChange, onSubmit, onSkip, step.answer,
            disabled: finished)
      },
      if (step.userAnswer != null &&
          (step.type == InputType.write ||
              step.type == InputType.compose ||
              step.type == InputType.pronounce))
        Container(
          margin: const EdgeInsets.only(top: 32),
          child: CustomBox(
            backgroundColor: step.isCorrect!
                ? Theme.of(context).colorScheme.tertiary.withOpacity(0.4)
                : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            child: Text(
              step.isCorrect! ? 'Correct!' : 'Incorrect: ${step.answer}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
    ]);
  }
}

class MockChatInputWidget extends StatelessWidget {
  final InputStep step;
  final void Function(String) onChange;
  final String currentAnswer;
  final void Function() onSubmit;
  final void Function() onSkip;
  const MockChatInputWidget(
      {required this.step,
      required this.onChange,
      required this.currentAnswer,
      required this.onSubmit,
      required this.onSkip,
      super.key});

  @override
  Widget build(BuildContext context) {
    bool disabled = step.userAnswer != null;
    return switch (step.type) {
      InputType.select => SelectionInput(currentAnswer, step.options!, (ans) {
          onChange(ans);
          onSubmit();
        }, disabled: disabled),
      InputType.compose => ComposeInput(step.options!, onChange,
          disabled: disabled, onSubmit: onSubmit, showSendBtn: true),
      InputType.pronounce => PronounciationInput(
          onChange, onSubmit, onSkip, step.answer,
          disabled: disabled),
      _ => throw Exception("Invalid input type for chat")
    };
  }
}
