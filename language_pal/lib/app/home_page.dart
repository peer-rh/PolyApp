import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat/ui/past_conversation_page.dart';
import 'package:poly_app/app/learn_track/ui/learn_track.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/app/user/ui/onboarding.dart';
import 'package:poly_app/app/user/ui/user_page.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/frosted_effect.dart';
import 'package:poly_app/common/ui/loading_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userP = ref.watch(userProvider);

    switch (userP.state) {
      case UserState.loading:
        return const LoadingPage();
      case UserState.onboarding:
        return const OnboardingPage();
      case UserState.loaded:
        return const NavigationPage();
    }
  }
}

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const LearnTrackPage();
      case 1:
        return const PastConversationListPage();
      case 2:
        return const UserPage();
      default:
        return const Text("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: FrostedEffect(
        child: Container(
            height: 64 + MediaQuery.of(context).padding.bottom,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border(
              top: BorderSide(
                  color: Theme.of(context).colorScheme.surface, width: 1.0),
            )),
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavBarIcon(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    selected: _selectedIndex == 0,
                    inactiveIcon: CustomIcons.scholaroutline,
                    icon: CustomIcons.scholar),
                _NavBarIcon(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    selected: _selectedIndex == 1,
                    inactiveIcon: CustomIcons.chartupoutline,
                    icon: CustomIcons.chartup),
                _NavBarIcon(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                    selected: _selectedIndex == 2,
                    inactiveIcon: CustomIcons.accountcircleoutline,
                    icon: CustomIcons.accountcircle),
              ],
            )),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final void Function() onPressed;
  final bool selected;
  final IconData icon;
  final IconData? inactiveIcon;
  const _NavBarIcon(
      {required this.onPressed,
      required this.selected,
      required this.icon,
      this.inactiveIcon,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: Container(
          width: 64,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: selected ? Theme.of(context).colorScheme.primary : null,
              borderRadius: BorderRadius.circular(8)),
          child: Icon(
            selected ? icon : inactiveIcon ?? icon,
            size: 32,
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onBackground,
          )),
    );
  }
}
