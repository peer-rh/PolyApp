import 'package:flutter/material.dart';
import 'package:poly_app/app/lessons/common/ui.dart';

class WriteInput extends StatefulWidget {
  final void Function(String) onChange;
  final bool disabled;
  const WriteInput(this.onChange, this.disabled, {super.key});

  @override
  State<WriteInput> createState() => _WriteInputState();
}

class _WriteInputState extends State<WriteInput> {
  late TextEditingController _cont;

  @override
  initState() {
    super.initState();
    _cont = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    _cont.addListener(() {
      widget.onChange(_cont.text);
    });
    return CustomBox(
      borderColor: Theme.of(context).colorScheme.surface,
      child: TextField(
        readOnly: widget.disabled,
        autocorrect: false,
        onSubmitted: (s) {
          widget.onChange(s);
        },
        textInputAction: TextInputAction.done,
        controller: _cont,
        textAlignVertical: TextAlignVertical.top,
        maxLines: 5,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: 'Type your answer here',
          border: InputBorder.none,
        ),
      ),
    );
  }
}
