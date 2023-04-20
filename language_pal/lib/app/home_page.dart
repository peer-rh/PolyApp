import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/scenario/ui/select_scenario_page.dart';
import 'package:language_pal/app/user/logic/user_provider.dart';
import 'package:language_pal/app/user/presentation/onboarding.dart';
import 'package:language_pal/common/ui/loading_page.dart';

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
        return const SelectScenarioPage();
    }
  }
}
