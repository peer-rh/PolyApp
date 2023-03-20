import 'package:flutter/material.dart';
import 'package:language_pal/auth/authProvider.dart';
import 'package:language_pal/auth/components/signInButton.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailCont = TextEditingController();
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
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, ap, _) {
          return Stack(children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailCont,
                    decoration: const InputDecoration(
                      hintText: "Write Email...",
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (errorMsg != null)
                    Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 5),
                  CustomAuthButton(
                      onPressed: () {
                        runAuth(() => ap.forgotPassword(emailCont.text));
                      },
                      text: "Send Reset Email"),
                ],
              ),
            ),
          ]);
        },
      ),
    );
  }
}
