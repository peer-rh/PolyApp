import 'package:flutter/material.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/auth/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  UserModel thisUser = UserModel("", "", "de", 0);
  final learnCont = TextEditingController();

  @override
  void didChangeDependencies() {
    AuthProvider ap = Provider.of(context);
    thisUser.email = ap.firebaseUser!.email!;
    thisUser.ownLang = AppLocalizations.of(context)!.localeName;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.onboarding_title),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Provider.of<AuthProvider>(context, listen: false)
                .setUserModel(thisUser);
          },
          child: const Icon(Icons.arrow_forward),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                  AppLocalizations.of(context)!.onboarding_learn_lang_question),
              const SizedBox(
                width: 10,
              ),
              DropdownButton<String>(
                value: thisUser.learnLang,
                onChanged: (String? newValue) {
                  setState(() {
                    thisUser.learnLang = newValue!;
                  });
                },
                items: const [
                  DropdownMenuItem<String>(
                    value: "en",
                    child: Text("English"),
                  ),
                  DropdownMenuItem<String>(
                    value: "de",
                    child: Text("German"),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
