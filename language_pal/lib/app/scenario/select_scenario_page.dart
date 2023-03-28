import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:language_pal/app/chat/presentation/chat_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectScenarioPage extends StatefulWidget {
  const SelectScenarioPage({Key? key}) : super(key: key);

  @override
  State<SelectScenarioPage> createState() => _SelectScenarioPageState();
}

class _SelectScenarioPageState extends State<SelectScenarioPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<List<ScenarioModel>>(
      builder: (context, scenarios, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: Text(
                  AppLocalizations.of(context)!.whatScenario,
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
                                      scenario: scenarios[index],
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
                            if (scenarios[index].userScore != null)
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: scenarios[index].userScore! >=
                                          scoreCompletedCutoff
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
                                            value: scenarios[index].userScore! /
                                                100,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        )),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  scenarios[index].emoji,
                                  style: const TextStyle(fontSize: 80),
                                ),
                                FittedBox(
                                  child: Text(
                                    scenarios[index].name,
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
        );
      },
    );
  }
}
