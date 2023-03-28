import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/scenario/scenario_provider.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:language_pal/app/user/logic/past_conversations.dart';
import 'package:language_pal/app/user/logic/use_cases.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/auth/models/user_model.dart';
import 'package:language_pal/common/languages.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Messages> conversations = [];
  List<UseCaseModel> useCases = [];
  List<ScenarioModel> scenarios = [];

  Future<void> loadScenarios() async {
    AuthProvider ap = context.read();
    final tmp = await loadScenarioModels(
      ap.user!.learnLang,
      ap.user!.appLang,
      ap.user!.scenarioScores,
      (await loadUseCaseModel(ap.user!.useCase, ap.user!.appLang))!.recommended,
    );
    setState(() {
      scenarios = tmp;
    });
  }

  void loadConversations() async {
    AuthProvider ap = context.read<AuthProvider>();
    var tmp = await loadPastConversations(scenarios, ap.firebaseUser!.uid);
    setState(() {
      conversations = tmp;
    });
  }

  void loadUseCases() async {
    AuthProvider ap = context.read<AuthProvider>();
    var tmp = await loadUseCaseModels(ap.user!.appLang);
    setState(() {
      useCases = tmp;
    });
  }

  @override
  void didChangeDependencies() async {
    await loadScenarios();
    loadConversations();
    loadUseCases();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider ap = context.watch();
    return Scaffold(
      appBar: AppBar(
        title: const Text("User"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(FontAwesomeIcons.circleUser, size: 54),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        ap.firebaseUser!.displayName ?? ap.firebaseUser!.email!,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    if (ap.firebaseUser!.displayName != null)
                      Text(ap.firebaseUser!.email!),
                  ],
                ),
                const Expanded(
                  child: SizedBox(),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    ap.signOut();
                  },
                )
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.language, size: 54),
                const SizedBox(width: 16),
                Expanded(
                  child: Table(
                    children: [
                      TableRow(children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text(
                              AppLocalizations.of(context)!.user_page_app_lang,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        DropdownButton(
                          value: ap.user!.appLang,
                          items: supportedAppLanguages().map((e) {
                            return DropdownMenuItem(
                                value: e.code,
                                child: Text("${e.emoji}${e.getName(context)}"));
                          }).toList(),
                          onChanged: (e) {
                            UserModel newUser = ap.user!;
                            newUser.appLang = e!;
                            ap.setUserModel(newUser);
                          },
                        )
                      ]),
                      TableRow(children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text(
                              AppLocalizations.of(context)!
                                  .user_page_learn_lang,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        DropdownButton(
                          value: ap.user!.learnLang,
                          items: supportedLearnLanguages().map((e) {
                            return DropdownMenuItem(
                                value: e.code,
                                child: Text("${e.emoji}${e.getName(context)}"));
                          }).toList(),
                          onChanged: (e) {
                            UserModel newUser = ap.user!;
                            newUser.learnLang = e!;
                            ap.setUserModel(newUser);
                          },
                        )
                      ]),
                      TableRow(children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text(
                              AppLocalizations.of(context)!.user_page_use_case,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        DropdownButton(
                          isExpanded: true,
                          value: ap.user!.useCase,
                          items: useCases
                              .map((e) => DropdownMenuItem(
                                  value: e.uniqueId,
                                  child: Text(
                                    e.emoji + e.title,
                                    softWrap: false,
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                  )))
                              .toList(),
                          onChanged: (e) {
                            UserModel newUser = ap.user!;
                            newUser.useCase = e!;
                            ap.setUserModel(newUser);
                          },
                        )
                      ]),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.user_page_conversations_title,
                style: Theme.of(context).textTheme.headlineSmall),
            if (conversations.isEmpty)
              Text(AppLocalizations.of(context)!.user_page_no_conversations),
            Expanded(
                child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(conversations[index].scenario.emoji),
                  title: Text(conversations[index].scenario.name),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
              itemCount: conversations.length,
            ))
          ],
        ),
      ),
    );
  }
}
