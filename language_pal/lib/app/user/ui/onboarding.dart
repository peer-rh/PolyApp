import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/user/data/user_model.dart';
import 'package:language_pal/app/user/logic/user_provider.dart';
import 'package:language_pal/app/user/ui/components/big_selectable_button.dart';
import 'package:language_pal/auth/logic/auth_provider.dart';
import 'package:language_pal/common/logic/languages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_pal/common/logic/use_case_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  UserModel thisUser = UserModel("", "", [], "");
  final learnCont = TextEditingController();
  int currentStep = 0;

  @override
  void didChangeDependencies() async {
    thisUser.uid = ref.read(authProvider).currentUser!.uid;
    thisUser.email = ref.read(authProvider).currentUser!.email ?? "";
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> steps = [
      Column(
        children: [
          Text(AppLocalizations.of(context)!.onboarding_use_case_question,
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 30),
          Expanded(
              child: ListView(
                  children: ref
                      .read(useCaseProvider)
                      .values
                      .map((e) => BigSelectableButton(
                          selected: thisUser.useCase == e.uniqueId,
                          emoji: e.emoji,
                          title: e.title,
                          onTap: () {
                            setState(() {
                              thisUser.useCase = e.uniqueId;
                            });
                          }))
                      .toList())),
        ],
      ),
      Column(
        children: [
          Text(AppLocalizations.of(context)!.onboarding_learn_lang_question,
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: supportedLearnLanguages()
                  .map((lang) => BigSelectableButton(
                      selected: thisUser.learnLangList.isNotEmpty &&
                          thisUser.learnLangList.first == lang.code,
                      emoji: lang.flag,
                      title: lang.getName(context),
                      onTap: () {
                        setState(() {
                          thisUser.learnLangList = [lang.code];
                        });
                      }))
                  .toList(),
            ),
          ),
        ],
      )
    ];
    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Stack(children: [
                steps[currentStep],
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        child: (currentStep == 0)
                            ? const Icon(Icons.close)
                            : const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (currentStep == 0) {
                            ref.read(authProvider).signOut();
                          } else {
                            setState(() {
                              currentStep--;
                            });
                          }
                        },
                      ),
                      FloatingActionButton(
                        child: (currentStep == steps.length - 1)
                            ? const Icon(Icons.check)
                            : const Icon(Icons.arrow_forward),
                        onPressed: () {
                          if (currentStep == 0 && thisUser.useCase == "") {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .onboarding_must_select_option)));
                          } else if (currentStep == 1 &&
                              thisUser.learnLangList == []) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .onboarding_must_select_option)));
                          } else {
                            if (currentStep == steps.length - 1) {
                              ref.read(userProvider).setUserModel(thisUser);
                            } else {
                              setState(() {
                                currentStep++;
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                )
              ]))),
    );
  }
}
