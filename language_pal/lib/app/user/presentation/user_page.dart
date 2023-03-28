import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:language_pal/app/chat/models/messages.dart';
import 'package:language_pal/app/scenario/scenarios_model.dart';
import 'package:language_pal/app/user/logic/past_conversations.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/auth/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Messages> conversations = [];

  void loadConversations() async {
    AuthProvider ap = context.read<AuthProvider>();
    var tmp = await loadPastConversations(
        context.read<List<ScenarioModel>>(), ap.firebaseUser!.uid);
    setState(() {
      conversations = tmp;
    });
  }

  @override
  void initState() {
    super.didChangeDependencies();
    super.initState();
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
                          items: [
                            DropdownMenuItem(
                                value: "en",
                                child: Text(
                                    "🇬🇧${AppLocalizations.of(context)!.english}")),
                            DropdownMenuItem(
                                value: "de",
                                child: Text(
                                    "🇩🇪${AppLocalizations.of(context)!.german}")),
                          ],
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
                          items: [
                            DropdownMenuItem(
                                value: "en",
                                child: Text(
                                    "🇬🇧${AppLocalizations.of(context)!.english}")),
                            DropdownMenuItem(
                                value: "de",
                                child: Text(
                                    "🇩🇪${AppLocalizations.of(context)!.german}")),
                          ],
                          onChanged: (e) {
                            UserModel newUser = ap.user!;
                            newUser.learnLang = e!;
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
            Text(AppLocalizations.of(context)!.conversations_title,
                style: Theme.of(context).textTheme.headlineSmall),
            if (conversations.isEmpty)
              Text(AppLocalizations.of(context)!.no_conversations),
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
