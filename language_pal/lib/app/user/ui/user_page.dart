import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/user/data/user_model.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/app/user/ui/account_page.dart';
import 'package:poly_app/app/user/ui/membership.dart';
import 'package:poly_app/app/user/ui/push_notif.dart';
import 'package:poly_app/app/user/ui/streak.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/custom_nav_item.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';

class UserPage extends ConsumerStatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  Widget dayOfWeekCircle(String day, bool selected) {
    return Container(
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      height: 20,
      width: 20,
      child: Text(day,
          style: TextStyle(
              color: selected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userP = ref.watch(userProvider);
    const spacer = SizedBox(height: 24);

    final day2Char = {
      0: "M",
      1: "T",
      2: "W",
      3: "T",
      4: "F",
      5: "S",
      6: "S",
    };
    int streak = 0;
    print(userP?.lastActiveDates);
    DateTime? lastDate;
    for (DateTime date in userP?.lastActiveDates.reversed ?? []) {
      if (lastDate == null ||
          date == lastDate.subtract(const Duration(days: 1))) {
        streak++;
        lastDate = date;
      } else {
        break;
      }
    }

    List<Widget> lastDays = [];
    for (int i = 0; i < 5; i++) {
      lastDays.add(dayOfWeekCircle(
          day2Char[(DateTime.now().weekday - i) % 7]!,
          userP?.lastActiveDates.contains(today.subtract(Duration(days: i))) ??
              false));
    }
    return Scaffold(
        appBar: const FrostedAppBar(
          title: Text("User"),
        ),
        extendBodyBehindAppBar: true,
        body: userP == null
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView(
                  children: [
                    CustomNavListItem(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AccountPage()));
                        },
                        enabled: true,
                        title: Text(
                          "Account",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        icon: CustomIcons.accout),
                    spacer,
                    CustomNavListItem(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const MembershipPage()));
                        },
                        enabled: true,
                        title: Text(
                          "Membership",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        icon: Icons.paid),
                    spacer,
                    CustomNavListItem(
                        onTap: () {
                          showReminderDialogue(context);
                        },
                        enabled: true,
                        title: Text(
                          "Enable Study Reminders",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        icon: CustomIcons.clock),
                    spacer,
                    CustomNavListItem(
                        onTap: () {
                          showStreakCalendar(context, userP.lastActiveDates);
                        },
                        enabled: true,
                        title: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$streak day Streak",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Wrap(
                                spacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: lastDays.reversed
                                    .expand((e) => [
                                          e,
                                          Container(
                                              height: 2,
                                              width: 8,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface),
                                        ])
                                    .toList()
                                  ..removeLast())
                          ],
                        ),
                        icon: CustomIcons.calendar),
                  ],
                )));
  }
}
