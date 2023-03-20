import 'package:flutter/material.dart';
import 'package:language_pal/app/navigation.dart';
import 'package:language_pal/auth/authPage.dart';
import 'package:language_pal/auth/authProvider.dart';
import 'package:language_pal/theme.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: "LanguagePal",
        theme: lightTheme,
        darkTheme: darkTheme,
        home: Builder(
          builder: (context) {
            AuthProvider ap = Provider.of(context);
            if (ap.user == null) {
              return const AuthPage();
            } else {
              return Overlay(
                initialEntries: [
                  OverlayEntry(builder: (context) => const HomePage())
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
