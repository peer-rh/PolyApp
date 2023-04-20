import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/chat/data/conversation.dart';
import 'package:language_pal/app/chat/logic/past_conversation_provider.dart';
import 'package:language_pal/app/chat/ui/past_conversation_page.dart';
import 'package:language_pal/app/user/data/user_model.dart';
import 'package:language_pal/app/user/logic/user_provider.dart';
import 'package:language_pal/auth/logic/auth_provider.dart';
import 'package:language_pal/common/logic/languages.dart';
import 'package:language_pal/common/logic/scenario_provider.dart';
import 'package:language_pal/common/logic/use_case_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserPage extends ConsumerStatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  List<Conversation> convs = [];

  @override
  void didChangeDependencies() {
    ref
        .watch(
            pastConversationProvider(ref.read(authProvider).currentUser!.uid))
        .whenData((value) => convs = value);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final userP = ref.watch(userProvider);
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
                const Icon(Icons.account_circle_outlined, size: 54, fill: 0.0),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(userP.user?.email ?? "",
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(authProvider).signOut();
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
                              AppLocalizations.of(context)!
                                  .user_page_learn_lang,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        DropdownButton(
                          value: ref.read(userProvider).user?.learnLang,
                          items: supportedLearnLanguages().map((e) {
                            return DropdownMenuItem(
                                value: e.code,
                                child: Text("${e.flag}${e.getName(context)}"));
                          }).toList(),
                          onChanged: (e) {
                            UserModel newUser = userP.user!;
                            newUser.learnLang = e!;
                            userP.setUserModel(newUser);
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
                          value: userP.user!.useCase,
                          items: ref
                              .read(useCaseProvider)
                              .values
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
                            UserModel newUser = userP.user!;
                            newUser.useCase = e!;
                            userP.setUserModel(newUser);
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
            if (convs.isEmpty)
              Text(AppLocalizations.of(context)!.user_page_no_conversations)
            else
              Expanded(
                  child: ListView.builder(
                itemBuilder: (context, index) {
                  final scenario =
                      ref.read(scenarioProvider)[convs[index].scenarioId];
                  if (scenario == null) {
                    FirebaseCrashlytics.instance.recordError(
                        Exception(
                            "Scenario ${convs[index].scenarioId}not found"),
                        StackTrace.current);
                    return const SizedBox();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PastConversationPage(conv: convs[index])));
                    },
                    child: Card(
                      child: ListTile(
                        leading: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(scenario.emoji),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  value:
                                      (convs[index].rating?.totalScore ?? 0) /
                                          10,
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.primary),
                                ),
                              ),
                            ]),
                        title: Text(scenario.name),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  );
                },
                itemCount: convs.length,
              )),
          ],
        ),
      ),
    );
  }
}
