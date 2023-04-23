import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/user/data/user_model.dart';
import 'package:language_pal/app/user/logic/learn_language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_pal/app/user/logic/user_provider.dart';
import 'package:language_pal/app/user/ui/components/big_selectable_button.dart';
import 'package:language_pal/common/logic/languages.dart';

class SelectLearnLangTitle extends ConsumerWidget {
  const SelectLearnLangTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        _showSelectLearnLangMenuOverlay(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            "${ref.watch(learnLangProvider).flag} ${ref.watch(learnLangProvider).getName(context)}",
          ),
          const Icon(Icons.arrow_drop_down)
        ]),
      ),
    );
  }
}

class _SelectLearnLangMenu extends ConsumerWidget {
  final Function() onDismiss;
  const _SelectLearnLangMenu({required this.onDismiss, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        ModalBarrier(onDismiss: onDismiss, color: Colors.black54),
        Positioned(
            top: AppBar().preferredSize.height + kToolbarHeight + 8,
            right: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                children: [
                  for (var lang in ref.watch(learnLangListProvider))
                    _CustomButton(
                        smallText: lang.getName(context),
                        selected: lang == ref.watch(learnLangProvider),
                        icon: lang.flag,
                        onTap: () {
                          ref
                              .read(learnLangProvider.notifier)
                              .setLearnLanguage(lang);
                          onDismiss();
                        }),
                  _CustomButton(
                      smallText:
                          AppLocalizations.of(context)!.learn_lang_add_button,
                      icon: "+",
                      onTap: () {
                        onDismiss();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const AddLearnLangPage()));
                      }),
                ],
              ),
            )),
      ],
    );
  }
}

class _CustomButton extends StatelessWidget {
  final String smallText;
  final String icon;
  final bool selected;
  final Function() onTap;
  const _CustomButton(
      {required this.smallText,
      required this.icon,
      required this.onTap,
      this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        alignment: Alignment.center,
        height: 85,
        width: 85,
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon,
                    style: TextStyle(
                        fontSize: 32,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                FittedBox(
                    child: Text(smallText,
                        style: TextStyle(
                          fontSize: 16,
                          color: selected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showSelectLearnLangMenuOverlay(BuildContext context) {
  final overlayState = Overlay.of(context);
  OverlayEntry? overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      return _SelectLearnLangMenu(
        onDismiss: () {
          overlayEntry?.remove();
        },
      );
    },
  );
  overlayState.insert(overlayEntry);
}

class AddLearnLangPage extends ConsumerWidget {
  const AddLearnLangPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<LanguageModel> supportedLanguages = supportedLearnLanguages();
    ref.watch(learnLangListProvider).forEach((element) {
      supportedLanguages.remove(element);
    });

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.learn_lang_new_title),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              SizedBox(height: 16),
              for (var lang in supportedLanguages)
                BigSelectableButton(
                  emoji: lang.flag,
                  title: lang.getName(context),
                  onTap: () {
                    UserModel newU = ref.read(userProvider).user!;
                    newU.learnLangList.add(lang.code);
                    ref.read(userProvider).setUserModel(newU);

                    Navigator.of(context).pop();
                  },
                )
            ],
          ),
        ));
  }
}
