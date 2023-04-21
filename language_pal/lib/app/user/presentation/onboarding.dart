import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:language_pal/app/user/data/user_model.dart';
import 'package:language_pal/app/user/logic/user_provider.dart';
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
  UserModel thisUser = UserModel("", "", "", "");
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
                      .map((e) => CustomCard(
                              thisUser.useCase == e.uniqueId, e.emoji, e.title,
                              () {
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
                  .map((lang) => CustomCard(thisUser.learnLang == lang.code,
                          lang.flag, lang.getName(context), () {
                        setState(() {
                          thisUser.learnLang = lang.code;
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
                              thisUser.learnLang == "") {
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

class CustomCard extends StatelessWidget {
  bool selected;
  String emoji;
  String title;
  void Function() onTap;
  CustomCard(this.selected, this.emoji, this.title, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 1,
          color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 60)),
                const SizedBox(width: 16),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(title,
                        maxLines: 1,
                        style: GoogleFonts.nunito(
                            fontSize: 30,
                            color: selected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
