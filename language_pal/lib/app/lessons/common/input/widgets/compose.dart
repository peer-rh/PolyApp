import 'package:flutter/material.dart';
import 'package:poly_app/app/lessons/common/ui.dart';
import 'package:poly_app/common/ui/custom_circular_button.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:reorderables/reorderables.dart';

class ComposeInput extends StatefulWidget {
  final List<String> options;
  final void Function(String) onAnswer;
  final bool disabled;
  final void Function()? onSubmit;
  final bool showSendBtn;
  const ComposeInput(this.options, this.onAnswer,
      {this.disabled = false,
      this.onSubmit,
      this.showSendBtn = false,
      super.key});

  @override
  State<ComposeInput> createState() => _ComposeInputState();
}

class _ComposeInputState extends State<ComposeInput> {
  List<String> boxes = [];

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        String row = boxes.removeAt(oldIndex);
        boxes.insert(newIndex, row);
      });
    }

    var wrap = ReorderableWrap(
        spacing: 8.0,
        runSpacing: 8.0,
        onReorder: _onReorder,
        enableReorder: !widget.disabled,
        children: boxes
            .map((e) => GestureDetector(
                  onTap: widget.disabled
                      ? null
                      : () {
                          setState(() {
                            boxes.remove(e);
                          });
                        },
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.surface),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(e,
                          style: Theme.of(context).textTheme.bodyLarge)),
                ))
            .toList());

    var items = Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: widget.options
            .map((e) => InkWell(
                  onTap: widget.disabled || boxes.contains(e)
                      ? null
                      : () {
                          setState(() {
                            boxes.add(e);
                          });
                          widget.onAnswer(boxes.join(' '));
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.surface),
                        borderRadius: BorderRadius.circular(8),
                        color: boxes.contains(e)
                            ? Theme.of(context).colorScheme.surface
                            : null,
                      ),
                      child: Text(
                        e,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: boxes.contains(e)
                                  ? Theme.of(context).colorScheme.surface
                                  : null,
                            ),
                      )),
                ))
            .toList());

    return Column(children: [
      CustomBox(
        borderColor: Theme.of(context).colorScheme.surface,
        child: Row(children: [
          Expanded(
            child:
                (boxes.isNotEmpty) ? wrap : const Text("Tap on items to add"),
          ),
          if (widget.showSendBtn)
            Align(
              alignment: Alignment.center,
              child: CustomCircularButton(
                  color: boxes.isNotEmpty
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  icon: const Icon(CustomIcons.arrow_up),
                  onPressed: boxes.isNotEmpty ? widget.onSubmit : null,
                  size: 32),
            )
        ]),
      ),
      const SizedBox(height: 32),
      items
    ]);
  }
}