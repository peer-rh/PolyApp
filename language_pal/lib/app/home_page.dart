import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:language_pal/app/scenario/select_scenario_page.dart';
import 'package:language_pal/app/user/logic/use_cases.dart';
import 'package:language_pal/app/user/presentation/user_page.dart';
import 'package:language_pal/auth/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<List<ScenarioModel>> loadScn(AuthProvider ap) async {
    String appLang = ap.user!.appLang;
    UseCaseModel useCase = (await loadUseCaseModel(ap.user!.useCase, appLang))!;
    return await loadScenarioModels(
      ap.user!.learnLang,
      appLang,
      ap.user!.scenarioScores,
      useCase.recommended,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const Icon(FontAwesomeIcons.circleUser),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserPage(),
                    ));
              })
        ],
      ),
      body: const SelectScenarioPage(),
    );
  }
}
