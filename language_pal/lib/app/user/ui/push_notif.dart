import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/user/logic/push_notif.dart';
import 'package:poly_app/common/ui/custom_circular_button.dart';

class PushNotifSelection extends ConsumerWidget {
  const PushNotifSelection({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days2String = {
      1: "M",
      2: "T",
      3: "W",
      4: "T",
      5: "F",
      6: "S",
      7: "S",
    };
    final days = ref.watch(reminderProvider);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 1; i <= 7; i++)
          CustomCircularButton(
            icon: Text(days2String[i]!,
                style: TextStyle(
                    color: days.contains(i)
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface)),
            size: 48,
            color: days.contains(i)
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            onPressed: () {
              days.contains(i)
                  ? ref.read(reminderProvider.notifier).removeDay(i)
                  : ref.read(reminderProvider.notifier).addDay(i);
            },
          ),
      ],
    );
  }
}

void showReminderDialogue(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Study Reminders"),
          content: PushNotifSelection(),
          actions: [
            TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Done")),
          ],
        );
      });
}
