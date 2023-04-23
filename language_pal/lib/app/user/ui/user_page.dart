import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/user/data/user_model.dart';
import 'package:language_pal/app/user/logic/user_provider.dart';
import 'package:language_pal/auth/logic/auth_provider.dart';
import 'package:language_pal/common/logic/use_case_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserPage extends ConsumerStatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  @override
  Widget build(BuildContext context) {
    final userP = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("User"),
      ),
      body: userP.user == null
          ? Container()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_circle_outlined,
                          size: 54, fill: 0.0),
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
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .user_page_use_case,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
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
                                  newUser.useCase = e as String;
                                  userP.setUserModel(newUser);
                                },
                              )
                            ]),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
