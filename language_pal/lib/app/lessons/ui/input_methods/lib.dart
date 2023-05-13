import 'package:flutter/material.dart';
import 'package:poly_app/app/lessons/data/input_step.dart';
import 'package:poly_app/app/lessons/ui/input_methods/compose.dart';
import 'package:poly_app/app/lessons/ui/input_methods/pronounce.dart';
import 'package:poly_app/app/lessons/ui/input_methods/selection.dart';
import 'package:poly_app/app/lessons/ui/input_methods/write.dart';

class InputWidget extends StatelessWidget {
  final InputStep step;
  final void Function(String) onChange;
  final String currentAnswer;
  const InputWidget({
    required this.step,
    required this.onChange,
    required this.currentAnswer,
    super.key,
  });

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
      InputType.pronounce =>
        PronounciationInput(onChange, step.answer, disabled: disabled)
    };
  }
}
