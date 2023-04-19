import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:language_pal/app/user/logic/use_cases.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/auth/models/user_model.dart';
import 'package:language_pal/common/logic/languages.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  UserModel thisUser = UserModel(null, "", "", {});
  final learnCont = TextEditingController();
  int currentStep = 0;
  List<UseCaseModel> useCases = [];

  @override
  void didChangeDependencies() async {
    AuthProviderOld ap = Provider.of(context);
    thisUser.email = ap.firebaseUser!.email;
    super.didChangeDependencies();

    useCases =
        await loadUseCaseModels(AppLocalizations.of(context)!.localeName);
    setState(() {});
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
            child: ListView.builder(
                itemCount: useCases.length,
                itemBuilder: (context, i) {
                  return CustomCard(thisUser.useCase == useCases[i].uniqueId,
                      useCases[i].emoji, useCases[i].title, () {
                    setState(() {
                      thisUser.useCase = useCases[i].uniqueId;
                    });
                  });
                }),
          ),
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
                            context.read<AuthProviderOld>().signOut();
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
                              context
                                  .read<AuthProviderOld>()
                                  .setUserModel(thisUser);
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
