import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/lessons/common/input/data.dart';
import 'package:poly_app/app/lessons/common/ui.dart';
import 'package:poly_app/common/logic/abilities.dart';
import 'package:poly_app/common/logic/audio_provider.dart';
import 'package:poly_app/common/ui/custom_icons.dart';

class VocabPrompt extends ConsumerWidget {
  final InputStep step;
  const VocabPrompt({required this.step, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void playAudio(String path) async {
      ref.read(cachedVoiceProvider).play(path);
    }

    return CustomBox(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              switch (step.type) {
                InputType.listen => "Listen to this phrase",
                InputType.pronounce => "Pronounce this phrase",
                _ => "Translate this phrase"
              },
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            switch (step.type) {
              InputType.listen => GestureDetector(
                  onTap: () {
                    playAudio(step.audioUrl!);
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CustomIcons.volume,
                                size: 24,
                                color: Theme.of(context).colorScheme.onPrimary),
                            const SizedBox(width: 8),
                            Text(
                              "Listen",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                            )
                          ])),
                ),
              InputType.pronounce => Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          playAudio(step.audioUrl!);
                        },
                        icon: Icon(CustomIcons.volume,
                            color: Theme.of(context).colorScheme.onSurface),
                        iconSize: 36,
                      ),
                      const SizedBox(width: 4),
                      Text(step.prompt,
                          style: Theme.of(context).textTheme.titleSmall),
                    ]),
              _ => Text(
                  step.prompt,
                  style: Theme.of(context).textTheme.titleSmall,
                )
            },
            switch (step.type) {
              InputType.listen => TextButton(
                  onPressed: () {
                    customAlert(
                        context: context,
                        title: "Can't listen",
                        content:
                            "This will disable all listening exercises for the next 15 minutes",
                        onConfirm: () {
                          ref.read(cantListenProvider.notifier).setOn();
                        });
                  },
                  child: Text(
                    "I can't listen right now",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  )),
              InputType.pronounce => TextButton(
                  onPressed: () {
                    customAlert(
                        context: context,
                        title: "Can't talk",
                        content:
                            "This will disable all pronunciation exercises for the next 15 minutes",
                        onConfirm: () {
                          ref.read(cantTalkProvider.notifier).setOn();
                        });
                  },
                  child: Text(
                    "I can't talk right now",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  )),
              _ => const SizedBox(),
            }
          ],
        ));
  }

  void customAlert(
      {required BuildContext context,
      required String title,
      required String content,
      required void Function() onConfirm}) {
    Widget cancelButton = TextButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        )),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text("Cancel"),
    );
    Widget continueButton = FilledButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        )),
      ),
      child: const Text("Confirm"),
      onPressed: () {
        onConfirm();
        Navigator.of(context).pop();
      },
    );

    // Create the dialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: Text(title),
      content: Text(content),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }
}
