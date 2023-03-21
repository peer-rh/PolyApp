import 'package:flutter/material.dart';
import 'package:language_pal/app/user/userProvider.dart';
import 'package:language_pal/auth/authProvider.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  UserModel thisUser = UserModel("", null, "", "", 0);
  final ownCont = TextEditingController();
  final learnCont = TextEditingController();
  final nameCont = TextEditingController();
  var currentStep = 0;
  List<Step> getSteps() => [
        Step(
            state: currentStep > 0 ? StepState.complete : StepState.indexed,
            isActive: currentStep == 0,
            title: const Text("Name"),
            content: Column(children: [
              const Text("What should we call you?"),
              TextField(
                controller: nameCont,
              )
            ])),
        Step(
            state: currentStep > 1 ? StepState.complete : StepState.indexed,
            isActive: currentStep == 1,
            title: const Text("Learn"),
            content: Column(
              children: [
                const Text("What Lanfuage do you want to learn"),
                DropdownMenu(
                    initialSelection: "en",
                    controller: ownCont,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: "de", label: "German"),
                      DropdownMenuEntry(value: "en", label: "English")
                    ]),
              ],
            )),
        Step(
            state: currentStep > 2 ? StepState.complete : StepState.indexed,
            isActive: currentStep == 2,
            title: const Text("Own Language"),
            content: Column(
              children: [
                const Text("What Language do you know"),
                DropdownMenu(
                    initialSelection: "de",
                    controller: learnCont,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: "de", label: "German"),
                      DropdownMenuEntry(value: "es", label: "Spanish"),
                      DropdownMenuEntry(value: "it", label: "Italian"),
                      DropdownMenuEntry(value: "en", label: "English")
                    ]),
              ],
            ))
      ];

  @override
  void didChangeDependencies() {
    AuthProvider ap = Provider.of(context);
    thisUser.email = ap.firebaseUser?.email;
    thisUser.name = ap.firebaseUser?.displayName ?? "";
    if (thisUser.name != "") {
      setState(() {
        currentStep = 1;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    nameCont.addListener(() => thisUser.name = nameCont.value.text);
    ownCont.addListener(() => thisUser.ownLang = ownCont.value.text);
    learnCont.addListener(() => thisUser.learnLang = learnCont.value.text);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: currentStep,
          onStepTapped: (step) => setState(() {
            currentStep = step;
          }),
          onStepContinue: () {
            if (currentStep == 2) {
              AuthProvider ap = context.read();
              ap.setUserModel(thisUser);
            } else {
              setState(() {
                currentStep += 1;
              });
            }
          },
          steps: getSteps(),
        ),
      ),
    );
  }
}
