import 'package:flutter/material.dart';
import 'package:language_pal/auth/authProvider.dart';
import 'package:language_pal/auth/components/buttons.dart';
import 'package:language_pal/auth/components/oAuthButtons.dart';
import 'package:language_pal/auth/components/signInButton.dart';
import 'package:language_pal/auth/presentation/forgotPassword.dart';
import 'package:language_pal/auth/presentation/signUpPage.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  Function(Widget) changeChild;
  SignInPage(this.changeChild, {Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
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
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage("assets/logo.png"),
                  height: 100,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailCont,
                  decoration: const InputDecoration(
                    hintText: "Write Email...",
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
                TextField(
                  controller: passCont,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Write Password...",
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      widget
                          .changeChild(ForgotPasswordPage(widget.changeChild));
                    },
                    child: const Text("Forgot Password?")),
                if (errorMsg != null)
                  Text(
                    errorMsg!,
                    style: const TextStyle(color: Colors.red),
                  ),
                CustomAuthButton(
                  onPressed: () {
                    runAuth(() => ap.signInWithEmailAndPassword(
                        emailCont.text, passCont.text));
                  },
                  text: "Sign In",
                ),
                TextButton(
                    onPressed: () {
                      widget.changeChild(SignUpPage(widget.changeChild));
                    },
                    child: const Text("Don't have an Account yet? Sign Up!")),
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
          );
        },
      ),
    );
  }
}
