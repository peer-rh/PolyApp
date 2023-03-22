import 'package:flutter/material.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/auth/presentation/components/o_auth_buttons.dart';
import 'package:language_pal/auth/presentation/components/sign_in_button.dart';
import 'package:language_pal/auth/presentation/forgot_password.dart';
import 'package:language_pal/common/logo.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailCont = TextEditingController();
  final passCont = TextEditingController();
  String? errorMsg = "";
  bool signIn = true;

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
    Widget _forgotPassword = Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTapUp: (_) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ForgotPasswordPage()));
        },
        child: Text(
          "Forgot Password?",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );

    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, ap, _) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Logo(56),
                const SizedBox(height: 80),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailCont,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Email",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passCont,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Password"),
                ),
                const SizedBox(height: 5),
                signIn ? _forgotPassword : const SizedBox(height: 20),
                const SizedBox(height: 5),
                if (errorMsg != null)
                  Text(
                    errorMsg!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                const SizedBox(height: 5),
                CustomAuthButton(
                  onPressed: () {
                    signIn
                        ? runAuth(() => ap.signInWithEmailAndPassword(
                            emailCont.text, passCont.text))
                        : runAuth(() => ap.signUpWithEmailAndPassword(
                            emailCont.text, passCont.text));
                  },
                  text: signIn ? "Sign In" : "Sign Up",
                ),
                const SizedBox(height: 15),
                oAuthDivider(),
                const SizedBox(height: 15),
                OAuthButtons(ap),
                const SizedBox(height: 25),
                TextButton(
                    onPressed: () {
                      setState(() {
                        signIn = !signIn;
                      });
                    },
                    child: signIn
                        ? const Text("Don't have an Account yet? Sign Up!")
                        : const Text("Already have an Account? Sign In!")),
              ],
            ),
          );
        },
      ),
    );
  }
}
