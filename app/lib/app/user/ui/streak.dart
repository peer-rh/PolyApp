import 'package:flutter/material.dart';
import 'package:poly_app/app/user/data/user_model.dart';

class StreakCalendar extends StatelessWidget {
  final List<DateTime> activeDates;
  const StreakCalendar({required this.activeDates, super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    final thisSunday = today.add(Duration(days: 7 - today.weekday));
    for (int week = 0; week < 5; week++) {
      List<Widget> row = [];
      for (int day = 0; day < 7; day++) {
        DateTime date = thisSunday.subtract(Duration(days: 7 * week + day));
        bool isActive = activeDates.contains(date);
        if (date.isAfter(today)) {
          row.add(const SizedBox(width: 36));
          continue;
        }
        row.add(Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).colorScheme.primary : null,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            date.day.toString(),
            style: TextStyle(
              color: isActive
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ));
      }
      rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: row.reversed.toList(),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.reversed.toList(),
    );
  }
}

void showStreakCalendar(BuildContext context, List<DateTime> activeDates) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Activity"),
          content: StreakCalendar(activeDates: activeDates),
        );
      });
}
