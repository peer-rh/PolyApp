import 'package:flutter/material.dart';
import 'package:poly_app/app/lessons/common/input/data.dart';
import 'package:poly_app/app/lessons/common/input/widgets/compose.dart';
import 'package:poly_app/app/lessons/common/input/widgets/pronounce.dart';
import 'package:poly_app/app/lessons/common/input/widgets/selection.dart';
import 'package:poly_app/app/lessons/common/input/widgets/write.dart';

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
    bool disabled = step.userAnswer != null;
    return switch (step.type) {
      InputType.write => WriteInput(onChange, disabled),
      InputType.select || InputType.listen => SelectionInput(
          currentAnswer, step.options!, onChange,
          disabled: disabled),
      InputType.compose =>
        ComposeInput(step.options!, onChange, disabled: disabled),
      InputType.pronounce => PronounciationInput(
          onChange, onSubmit, onSkip, step.answer,
          disabled: disabled)
    };
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
