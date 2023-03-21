import 'package:flutter/material.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/auth/presentation/components/sign_in_button.dart';
import 'package:language_pal/auth/presentation/components/o_auth_buttons.dart';
import 'package:language_pal/auth/presentation/sign_in_page.dart';
import 'package:language_pal/common/logo.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  Function(Widget) changeChild;
  SignUpPage(this.changeChild, {Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailCont = TextEditingController();
  final passCont = TextEditingController();
  String? errorMsg = "";

  void runAuth(Function() f) async {
    try {
      await f();
      setState(() {
        errorMsg = null;
      });
    } on AuthException catch (e) {
      setState(() {
        errorMsg = e.msg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, ap, _) {
          return Stack(children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Logo(56),
                  const SizedBox(
                    height: 80,
                  ),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailCont,
                    decoration: const InputDecoration(
                      hintText: "Write Email...",
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passCont,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Write Password...",
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (errorMsg != null)
                    Text(
                      errorMsg!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  const SizedBox(
                      height:
                          35), // NOTE: covers the space which Forgot Password button would take, may not be universal
                  CustomAuthButton(
                    onPressed: () {
                      runAuth(() => ap.signUpWithEmailAndPassword(
                          emailCont.text, passCont.text));
                    },
                    text: "Sign Up",
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                      onPressed: () {
                        widget.changeChild(SignInPage(widget.changeChild));
                      },
                      child: const Text("Already have an Account? Sign In!")),
                  const SizedBox(height: 20),
                  OAuthButtons(ap),
                  const SizedBox(
                    height: 50,
                  ),
                  TextButton(
                      onPressed: () {
                        ap.signInAnonymously();
                      },
                      child: const Text("Continue as Guest"))
                ],
              ),
            ),
          ]);
        },
      ),
    );
  }
}
