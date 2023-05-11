import 'package:flutter/material.dart';
import 'package:poly_app/app/lessons/ui/components/custom_box.dart';
import 'package:poly_app/common/ui/custom_ink_well.dart';

class SelectionInput extends StatelessWidget {
  final String? selected;
  final List<String> options;
  final void Function(String) onSelected;
  final bool disabled;

  SelectionInput(this.selected, this.options, this.onSelected,
      {this.disabled = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(runSpacing: 16, children: [
      for (var i = 0; i < options.length; i++) selectableBox(context, i),
    ]);
  }

  Widget selectableBox(BuildContext context, int index) {
    bool thisSelected = selected == options[index];
    return CustomInkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: disabled
            ? null
            : () {
                onSelected(options[index]);
              },
        child: CustomBox(
          backgroundColor: thisSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : null,
          borderColor: thisSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderWidth: thisSelected ? 2 : 1,
          child: Text(options[index],
              style: Theme.of(context).textTheme.bodyLarge),
        ));
  }
}
