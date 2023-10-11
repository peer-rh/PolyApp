import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/lessons/common/ui.dart';
import 'package:poly_app/common/logic/audio_provider.dart';
import 'package:poly_app/common/ui/custom_ink_well.dart';

class SelectionInput extends ConsumerWidget {
  final String? selected;
  final List<String> options;
  final void Function(String) onSelected;
  final bool disabled;
  final String? correctAnswer;

  const SelectionInput(this.selected, this.options, this.onSelected,
      {this.disabled = false, this.correctAnswer, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceProv = ref.watch(voiceProvider);
    return Wrap(runSpacing: 16, children: [
      for (var i = 0; i < options.length; i++)
        selectableBox(context, i, voiceProv),
    ]);
  }

  Widget selectableBox(
      BuildContext context, int index, VoiceProvider voiceProv) {
    bool thisSelected = selected == options[index];
    bool isCorrect = correctAnswer == options[index];
    return CustomInkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: disabled
            ? null
            : () {
                voiceProv.play(options[index]);
                onSelected(options[index]);
              },
        child: CustomBox(
          backgroundColor: isCorrect
              ? Theme.of(context).colorScheme.tertiary.withOpacity(0.2)
              : thisSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : null,
          borderColor: isCorrect
              ? Theme.of(context).colorScheme.tertiary
              : thisSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
          borderWidth: thisSelected || isCorrect ? 2 : 1,
          child: Text(options[index],
              style: Theme.of(context).textTheme.bodyLarge),
        ));
  }
}
