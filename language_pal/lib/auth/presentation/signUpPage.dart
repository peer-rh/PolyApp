import 'package:flutter/material.dart';
import 'package:language_pal/auth/authProvider.dart';
import 'package:language_pal/auth/presentation/signInPage.dart';
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
                  if (errorMsg != null)
                    Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ElevatedButton(
                      onPressed: () {
                        runAuth(() => ap.signUpWithEmailAndPassword(
                            emailCont.text, passCont.text));
                      },
                      child: const Text("Sign Up")),
                  TextButton(
                      onPressed: () {
                        widget.changeChild(SignInPage(widget.changeChild));
                      },
                      child: const Text("Already have an account? Sign in.")),
                  ElevatedButton(
                    onPressed: () {
                      runAuth(ap.signInWithGoogle);
                    },
                    child: const Text("Sign In With Google"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      runAuth(ap.signInWithApple);
                    },
                    child: const Text("Sign In With Apple"),
                  ),
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
