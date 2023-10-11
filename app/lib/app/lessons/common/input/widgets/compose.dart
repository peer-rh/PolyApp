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
  final String? hint;
  const ComposeInput(this.options, this.onAnswer,
      {this.disabled = false,
      this.onSubmit,
      this.showSendBtn = false,
      this.hint,
      super.key});

  @override
  State<ComposeInput> createState() => _ComposeInputState();
}

class _ComposeInputState extends State<ComposeInput> {
  List<String> boxes = [];

  @override
  Widget build(BuildContext context) {
    void onReorder(int oldIndex, int newIndex) {
      setState(() {
        String row = boxes.removeAt(oldIndex);
        boxes.insert(newIndex, row);
      });
    }

    var wrap = ReorderableWrap(
        spacing: 8.0,
        runSpacing: 8.0,
        onReorder: onReorder,
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
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.hint != null && boxes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CustomCircularButton(
                  outlineColor: Theme.of(context).colorScheme.onBackground,
                  icon: const Icon(CustomIcons.questionmark, size: 18),
                  onPressed: () {
                    showHint(context, widget.hint!);
                  },
                  size: 32),
            ),
          Expanded(
            child: CustomBox(
              borderColor: Theme.of(context).colorScheme.surface,
              child: (boxes.isNotEmpty)
                  ? wrap
                  : Container(
                      alignment: Alignment.centerLeft,
                      height: 34,
                      child: const Text("Tap on items to add")),
            ),
          ),
          if (widget.showSendBtn)
            Container(
              margin: const EdgeInsets.only(left: 16),
              alignment: Alignment.center,
              child: CustomCircularButton(
                  color: boxes.isNotEmpty
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  icon: Icon(
                    CustomIcons.arrow_up,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: boxes.isNotEmpty ? widget.onSubmit : null,
                  size: 32),
            )
        ],
      ),
      const SizedBox(height: 32),
      items
    ]);
  }
}

void showHint(BuildContext context, String hint) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hint, style: Theme.of(context).textTheme.bodyLarge),
          ],
        )),
  );
}
