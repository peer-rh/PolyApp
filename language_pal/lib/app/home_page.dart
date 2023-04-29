import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/chat/ui/past_conversation_page.dart';
import 'package:poly_app/app/scenario/ui/select_scenario_page.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/app/user/ui/onboarding.dart';
import 'package:poly_app/app/user/ui/user_page.dart';
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
        return const SelectScenarioPage();
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
        bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() {
                  _selectedIndex = index;
                }),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.chat_outlined),
                label: "Chat",
                selectedIcon: Icon(Icons.chat),
              ),
              NavigationDestination(
                  icon: Icon(Icons.history_rounded), label: "History"),
              NavigationDestination(
                icon: Icon(Icons.account_circle_outlined),
                label: "User",
                selectedIcon: Icon(Icons.account_circle),
              )
            ]));
  }
}
