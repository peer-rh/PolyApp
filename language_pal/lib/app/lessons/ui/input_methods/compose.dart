import 'package:flutter/material.dart';
import 'package:poly_app/app/lessons/ui/components/custom_box.dart';
import 'package:reorderables/reorderables.dart';

class ComposeInput extends StatefulWidget {
  final List<String> options;
  final void Function(String) onAnswer;
  final bool disabled;
  const ComposeInput(this.options, this.onAnswer,
      {this.disabled = false, super.key});

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
        onNoReorder: (int index) {
          //this callback is optional
          debugPrint(
              '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
        },
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
                  onTap: widget.disabled
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
        child: (boxes.isNotEmpty) ? wrap : const Text("Tap on items to add"),
      ),
      const SizedBox(height: 32),
      items
    ]);
  }
}
