import 'package:flutter/material.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/auth/presentation/components/o_auth_buttons.dart';
import 'package:language_pal/auth/presentation/components/sign_in_button.dart';
import 'package:language_pal/auth/presentation/forgot_password.dart';
import 'package:language_pal/auth/presentation/sign_up_page.dart';
import 'package:language_pal/common/logo.dart';
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
                const Logo(56),
                const SizedBox(height: 80),
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
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTapUp: (_) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordPage()));
                      // widget
                      //     .changeChild(ForgotPasswordPage(widget.changeChild));
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                if (errorMsg != null)
                  Text(
                    errorMsg!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                const SizedBox(height: 10),
                CustomAuthButton(
                  onPressed: () {
                    runAuth(() => ap.signInWithEmailAndPassword(
                        emailCont.text, passCont.text));
                  },
                  text: "Sign In",
                ),
                const SizedBox(height: 10),
                TextButton(
                    onPressed: () {
                      widget.changeChild(SignUpPage(widget.changeChild));
                    },
                    child: const Text("Don't have an Account yet? Sign Up!")),
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
          );
        },
      ),
    );
  }
}
