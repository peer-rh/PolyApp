import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomTopicGenerator extends ConsumerWidget {
  CustomTopicGenerator({super.key});
  final _cont = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Topic"),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Container(
        padding: EdgeInsets.only(
            left: 24, right: 24, bottom: MediaQuery.of(context).padding.bottom),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8)),
            child: Text("Desribe what you want to learn",
                style: Theme.of(context).textTheme.titleSmall),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceVariant),
                borderRadius: BorderRadius.circular(8)),
            child: TextField(
              textInputAction: TextInputAction.done,
              controller: _cont,
              textAlignVertical: TextAlignVertical.top,
              maxLines: 5,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'I want to learn...',
                border: InputBorder.none,
              ),
            ),
          ),
          const Spacer(),
          FilledButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
                minimumSize:
                    MaterialStateProperty.all(const Size.fromHeight(48)),
              ),
              onPressed: () {
                // TODO: implement
              },
              child: const Text("Generate")),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class CustomTopicViewer extends ConsumerWidget {
  const CustomTopicViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
