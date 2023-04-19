import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/home_page.dart';
import 'package:language_pal/app/user/presentation/onboarding.dart';
import 'package:language_pal/auth/logic/auth_provider.dart';
import 'package:language_pal/auth/presentation/auth_page.dart';
import 'package:language_pal/common/ui/loading_page.dart';
import 'package:language_pal/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: "LanguagePal",
      theme: lightTheme,
      darkTheme: darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ref.watch(authStateChangesProvider).when(
            data: (user) {
              if (user == null) {
                return const AuthPage();
              } else {
                return const HomePage();
              }
            },
            loading: () => const LoadingPage(),
            error: (e, s) => Text(e.toString()),
          ),
    );
  }
}
