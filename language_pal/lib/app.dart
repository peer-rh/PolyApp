import 'package:flutter/material.dart';
import 'package:language_pal/app/home_page.dart';
import 'package:language_pal/app/loading_page.dart';
import 'package:language_pal/app/user/presentation/onboarding.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/auth/presentation/auth_page.dart';
import 'package:language_pal/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        builder: (context, _) {
          return MaterialApp(
            title: "LanguagePal",
            theme: lightTheme,
            darkTheme: darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                AuthProvider ap = context.watch();
                switch (ap.state) {
                  case AuthState.loading:
                    return const LoadingPage();
                  case AuthState.authenticated:
                    return const HomePage();
                  case AuthState.unauthenticated:
                    return const AuthPage();
                  case AuthState.onboarding:
                    return const OnboardingPage();
                  default:
                    return const Text("Error");
                }
              },
            ),
          );
        });
  }
}
