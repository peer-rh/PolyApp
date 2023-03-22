import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:language_pal/app/chat/models/scenarios_model.dart';
import 'package:language_pal/app/chat/presentation/chat_page.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class SelectScenarioPage extends StatefulWidget {
  const SelectScenarioPage({Key? key}) : super(key: key);

  @override
  State<SelectScenarioPage> createState() => _SelectScenarioPageState();
}

class _SelectScenarioPageState extends State<SelectScenarioPage> {
  List<ScenarioModel> scenarios = [];

  void loadScenarios(String language) async {
    var tmp = await loadScenarioModels(language);
    setState(() {
      scenarios = tmp;
    });
  }

  @override
  void initState() {
    super.initState();
    String learnLang =
        Provider.of<AuthProvider>(context, listen: false).user!.learnLang;
    loadScenarios(learnLang);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          child: ListView(children: [
            Container(
              margin: const EdgeInsets.only(bottom: 30),
              child: Text(
                "What Scenario do you want to practice?",
                style: GoogleFonts.nunito(fontSize: 32),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: MasonryGridView.builder(
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
                            constraints: const BoxConstraints(minHeight: 164),
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
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
                          ),
                        ),
                      );
                    },
                    itemCount: scenarios.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics())),
          ]),
        ));
  }
}
