import 'package:flutter/material.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:language_pal/auth/presentation/components/sign_in_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        title:  Text(AppLocalizations.of(context)!.forgot_password_title),
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
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.auth_email,
                    ),
                  ),
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
                        runAuth(() => ap.forgotPassword(emailCont.text));
                      },
                      text: AppLocalizations.of(context)!.forgot_password_button),
                ],
              ),
            ),
          ]);
        },
      ),
    );
  }
}
