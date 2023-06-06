import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/ui/subchapter.dart';
import 'package:poly_app/app/smart_review/logic/custom_topic.dart';

class CustomTopicGenerator extends ConsumerStatefulWidget {
  const CustomTopicGenerator({Key? key}) : super(key: key);

  @override
  CustomTopicGeneratorState createState() => CustomTopicGeneratorState();
}

class CustomTopicGeneratorState extends ConsumerState<CustomTopicGenerator> {
  final _cont = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
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
              onPressed: () async {
                if (loading) {
                  return;
                }
                loading = true;
                setState(() {});
                // try {
                final id = await generateCustomTopic(_cont.text, ref);
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => SubchapterPage(id, () {})));
                }
                // } catch (e) {
                //   loading = false;
                //   setState(() {});
                //   if (context.mounted) {
                //     showDialog(
                //       context: context,
                //       builder: (context) => AlertDialog(
                //         title: const Text("Error | Try Again"),
                //         content: Text(e.toString()),
                //         actions: [
                //           TextButton(
                //             onPressed: () => Navigator.of(context).pop(),
                //             child: const Text("OK"),
                //           )
                //         ],
                //       ),
                //     );
                //   }
                // }
              },
              child: loading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : const Text("Generate")),
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
