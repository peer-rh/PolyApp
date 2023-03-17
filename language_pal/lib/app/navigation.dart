import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:language_pal/app/chat/presentation/selectScenarioPage.dart';
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
      create: (_) => UserProvider(authProvider.user as User),
      builder: (context, child) {
        UserProvider up = Provider.of(context);
        switch (up.status) {
          case Status.loading:
            return const CircularProgressIndicator();
          case Status.onboarding:
            return OnboardingPage();
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
    SelectScenarioPage(),
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
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
