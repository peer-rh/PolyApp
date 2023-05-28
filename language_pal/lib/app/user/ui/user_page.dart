import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/app/user/ui/account_page.dart';
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
    final spacer = const SizedBox(height: 24);

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
                        onTap: () {},
                        enabled: true,
                        title: Text(
                          "Membership",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        icon: Icons.paid),
                    spacer,
                    CustomNavListItem(
                        onTap: () {},
                        enabled: true,
                        title: Text(
                          "Gift 7 day trial",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        icon: CustomIcons.gift),
                    spacer,
                    CustomNavListItem(
                        onTap: () {},
                        enabled: true,
                        title: Text(
                          "Enable Study Reminders",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        icon: CustomIcons.clock),
                    spacer,
                    CustomNavListItem(
                        onTap: () {},
                        enabled: true,
                        title: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "7 day Streak",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Wrap(
                                spacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  dayOfWeekCircle("F", true),
                                  Container(
                                      height: 2,
                                      width: 8,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                  dayOfWeekCircle("S", true),
                                  Container(
                                      height: 2,
                                      width: 8,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                  dayOfWeekCircle("S", true),
                                  Container(
                                      height: 2,
                                      width: 8,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                  dayOfWeekCircle("M", true),
                                  Container(
                                      height: 2,
                                      width: 8,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                  dayOfWeekCircle("T", true)
                                ])
                          ],
                        ),
                        icon: CustomIcons.calendar),
                  ],
                )));
  }
}
