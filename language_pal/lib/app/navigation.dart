import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:language_pal/app/chat/presentation/selectScenarioPage.dart';
import 'package:language_pal/app/loadingPage.dart';
import 'package:language_pal/app/user/presentation/onboarding.dart';
import 'package:language_pal/app/user/presentation/userPage.dart';
import 'package:language_pal/app/user/userProvider.dart';
import 'package:language_pal/auth/authProvider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of(context);
    return ChangeNotifierProvider(
      create: (context) => UserProvider(authProvider.user as User),
      builder: (context, child) {
        UserProvider up = Provider.of(context);
        switch (up.status) {
          case Status.loading:
            return const LoadingPage();
          case Status.onboarding:
            return const OnboardingPage();
          case Status.loaded:
            return const NavWrapper();
          default:
            return const Text("Error");
        }
      },
    );
  }
}

class NavWrapper extends StatefulWidget {
  const NavWrapper({super.key});

  @override
  State<NavWrapper> createState() => _NavWrapperState();
}

class _NavWrapperState extends State<NavWrapper> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const SelectScenarioPage(),
    const UserPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.comment),
            selectedIcon: Icon(FontAwesomeIcons.solidComment),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.user),
            selectedIcon: Icon(FontAwesomeIcons.solidUser),
            label: 'User',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
