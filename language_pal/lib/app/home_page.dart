import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:language_pal/app/scenario/select_scenario_page.dart';
import 'package:language_pal/app/user/logic/use_cases.dart';
import 'package:language_pal/app/user/presentation/user_page.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<List<ScenarioModel>> loadScn(BuildContext context) async {
    String ownLang = context.read<AuthProvider>().user!.appLang;
    AuthProvider ap = context.read<AuthProvider>();
    UseCaseModel useCase = (await loadUseCaseModel(ap.user!.useCase, ownLang))!;
    return await loadScenarioModels(
      ap.user!.learnLang,
      ownLang,
      ap.user!.scenarioScores,
      useCase.recommended,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureProvider<List<ScenarioModel>>(
      initialData: [],
      create: (context) => loadScn(context),
      builder: (context, _) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          actions: [
            IconButton(
                icon: const Icon(FontAwesomeIcons.circleUser),
                onPressed: () {
                  List<ScenarioModel> scenarios =
                      context.read<List<ScenarioModel>>();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Provider(
                          create: (context) => scenarios,
                          child: const UserPage(),
                        ),
                      ));
                })
          ],
        ),
        body: const SelectScenarioPage(),
      ),
    );
  }
}
