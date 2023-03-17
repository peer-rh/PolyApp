import 'package:flutter/material.dart';
import 'package:language_pal/auth/authProvider.dart';
import 'package:language_pal/auth/presentation/signInPage.dart';
import 'package:language_pal/auth/presentation/signUpPage.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  Function(Widget) changeChild;
  ForgotPasswordPage(this.changeChild, {Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
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
                  if (errorMsg != null)
                    Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ElevatedButton(
                      onPressed: () {
                        runAuth(() => ap.forgotPassword(emailCont.text));
                      },
                      child: const Text("Send Reset Email")),
                  TextButton(
                      onPressed: () {
                        widget.changeChild(SignInPage(widget.changeChild));
                      },
                      child: const Text("Back to Sign In")),
                ],
              ),
            ),
          ]);
        },
      ),
    );
  }
}
