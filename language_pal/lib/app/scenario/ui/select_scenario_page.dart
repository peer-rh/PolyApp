import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:language_pal/app/chat/logic/store_conv.dart';
import 'package:language_pal/app/chat/ui/active_chat_page.dart';
import 'package:language_pal/app/scenario/data/personalizedScenario.dart';
import 'package:language_pal/app/user/logic/learn_language_provider.dart';
import 'package:language_pal/app/user/logic/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_pal/app/user/ui/select_learn_lang.dart';
import 'package:language_pal/common/logic/scenario_provider.dart';
import 'package:language_pal/common/logic/use_case_provider.dart';

class SelectScenarioPage extends ConsumerStatefulWidget {
  const SelectScenarioPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SelectScenarioPage> createState() => _SelectScenarioPageState();
}

class _SelectScenarioPageState extends ConsumerState<SelectScenarioPage> {
  List<PersonaliedScenario> scenariosInProgress = [];
  List<PersonaliedScenario> scenariosNormal = [];
  List<PersonaliedScenario> scenariosDone = [];

  void loadScenarios() async {
    final scenariosP = ref.watch(scenarioProvider);
    final user = ref.watch(userProvider).user;

    var tmp = await Future.wait(scenariosP.values.map((e) async {
      return PersonaliedScenario(
        scenario: e,
        inProgress: await conversationExists(
            ref.watch(learnLangProvider).code, e.uniqueId),
        useCaseRecommended: ref
            .read(useCaseProvider)[user?.useCase]!
            .recommended
            .contains(e.uniqueId),
      );
    }).toList());

    tmp.sort((a, b) => a.compareTo(b));

    scenariosInProgress = [];
    scenariosNormal = [];
    scenariosDone = [];

    for (var i = 0; i < tmp.length; i++) {
      if (tmp[i].inProgress) {
        scenariosInProgress.add(tmp[i]);
      } else {
        scenariosNormal.add(tmp[i]);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    loadScenarios();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const SelectLearnLangTitle()),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            if (scenariosInProgress.isNotEmpty)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  AppLocalizations.of(context)!.select_scenario_in_progress,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(
                  height: 8,
                ),
                MasonryGridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  itemBuilder: (context, index) {
                    return _ScenarioButton(scenariosInProgress[index]);
                  },
                  itemCount: scenariosInProgress.length,
                  shrinkWrap: true,
                ),
                const SizedBox(
                  height: 16,
                ),
              ]),
            if (scenariosNormal.isNotEmpty)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                (scenariosInProgress.isEmpty)
                    ? Text(
                        AppLocalizations.of(context)!.select_scenario_title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      )
                    : Text(
                        AppLocalizations.of(context)!
                            .select_scenario_not_in_progress,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                const SizedBox(
                  height: 8,
                ),
                MasonryGridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  itemBuilder: (context, index) {
                    return _ScenarioButton(scenariosNormal[index]);
                  },
                  itemCount: scenariosNormal.length,
                  shrinkWrap: true,
                ),
                const SizedBox(
                  height: 16,
                ),
              ]),
            if (scenariosDone.isNotEmpty)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  AppLocalizations.of(context)!.select_scenario_done,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(
                  height: 8,
                ),
                MasonryGridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  itemBuilder: (context, index) {
                    return _ScenarioButton(scenariosDone[index]);
                  },
                  itemCount: scenariosDone.length,
                  shrinkWrap: true,
                ),
                const SizedBox(
                  height: 16,
                ),
              ]),
          ],
        ),
      ),
    );
  }
}

class _ScenarioButton extends StatelessWidget {
  final PersonaliedScenario scenario;
  const _ScenarioButton(this.scenario);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        scenario: scenario.scenario,
                      )));
        },
        child: Container(
          height: 174,
          padding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              if (scenario.useCaseRecommended)
                Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      FontAwesomeIcons.solidStar,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 18,
                    )),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    scenario.scenario.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                  FittedBox(
                    child: Text(
                      scenario.scenario.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
