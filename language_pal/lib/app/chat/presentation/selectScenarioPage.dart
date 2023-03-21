import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:language_pal/app/chat/models/scenariosModel.dart';
import 'package:language_pal/app/chat/presentation/chatPage.dart';
import 'package:language_pal/app/user/userProvider.dart';
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
    String lang =
        Provider.of<UserProvider>(context, listen: false).u!.learnLang;
    loadScenarios(lang);
  }

  @override
  Widget build(BuildContext context) {
    String ownLang =
        Provider.of<UserProvider>(context, listen: false).u!.ownLang;
    String learnLang =
        Provider.of<UserProvider>(context, listen: false).u!.ownLang;
    return Container(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(children: [
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
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                          scenario: scenarios[index],
                                          ownLang: ownLang,
                                          learnLang: learnLang,
                                        )));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  scenarios[index].emoji,
                                  style: TextStyle(fontSize: 80),
                                ),
                                Text(
                                  scenarios[index].name,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                      fontSize: 24,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.w600),
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

class PersonChatButton extends StatelessWidget {
  final ScenarioModel aiBot;
  const PersonChatButton({Key? key, required this.aiBot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String learnLang =
        Provider.of<UserProvider>(context, listen: false).u!.learnLang;
    String ownLang =
        Provider.of<UserProvider>(context, listen: false).u!.ownLang;
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        scenario: aiBot,
                        ownLang: ownLang,
                        learnLang: learnLang,
                      )));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          color: Colors.grey[300],
          child: Center(
              child: Text(
            aiBot.name,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "nunito"),
          )),
        ));
  }
}
