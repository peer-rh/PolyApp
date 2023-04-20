import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:language_pal/app/chat/ui/active_chat_page.dart';
import 'package:language_pal/app/scenario/data/personalizedScenario.dart';
import 'package:language_pal/app/user/logic/user_provider.dart';
import 'package:language_pal/app/user/presentation/user_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_pal/common/logic/scenario_provider.dart';
import 'package:language_pal/common/logic/use_case_provider.dart';

class SelectScenarioPage extends ConsumerStatefulWidget {
  const SelectScenarioPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SelectScenarioPage> createState() => _SelectScenarioPageState();
}

class _SelectScenarioPageState extends ConsumerState<SelectScenarioPage> {
  List<PersonaliedScenario> scenarios = [];

  void loadScenarios() async {
    final scenariosP = ref.watch(scenarioProvider);
    final user = ref.watch(userProvider).user;
    // TODO: inProgress and bestScore
    var tmp = scenariosP.values.map((e) {
      return PersonaliedScenario(
        scenario: e,
        useCaseRecommended: ref
            .read(useCaseProvider)[user?.useCase]!
            .recommended
            .contains(e.uniqueId),
      );
    }).toList();

    tmp.sort((a, b) {
      return a.compareTo(b);
    });

    setState(() {
      scenarios = tmp;
    });
  }

  @override
  void didChangeDependencies() {
    loadScenarios();
    super.didChangeDependencies();
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 30),
              child: Text(
                AppLocalizations.of(context)!.select_scenario_question,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            MasonryGridView.builder(
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              itemBuilder: (context, index) {
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
                                    scenario: scenarios[index].scenario,
                                  )));
                    },
                    child: Container(
                      height: 174,
                      padding: const EdgeInsets.all(12),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          if (scenarios[index].useCaseRecommended)
                            Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  FontAwesomeIcons.solidStar,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  size: 18,
                                )),
                          if (scenarios[index].done != null)
                            Align(
                                alignment: Alignment.topLeft,
                                child: scenarios[index].done
                                    ? Icon(
                                        FontAwesomeIcons.check,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 18,
                                      )
                                    : SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          value:
                                              scenarios[index].bestScore! / 10,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      )),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                scenarios[index].scenario.emoji,
                                style: const TextStyle(fontSize: 80),
                              ),
                              FittedBox(
                                child: Text(
                                  scenarios[index].scenario.emoji,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                      fontSize: 24,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
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
              },
              itemCount: scenarios.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
            ),
          ],
        ),
      ),
    );
  }
}
