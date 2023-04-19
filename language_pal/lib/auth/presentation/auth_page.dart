import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/auth/data/auth_exception.dart';
import 'package:language_pal/auth/logic/auth_provider.dart';
import 'package:language_pal/auth/presentation/components/o_auth_buttons.dart';
import 'package:language_pal/auth/presentation/components/sign_in_button.dart';
import 'package:language_pal/auth/presentation/forgot_password.dart';
import 'package:language_pal/common/ui/logo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
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
    Widget forgotPassword = Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTapUp: (_) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ForgotPasswordPage()));
        },
        child: Text(
          AppLocalizations.of(context)!.forgot_password_link,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Logo(56),
              const SizedBox(height: 80),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [
                  AutofillHints.email,
                  AutofillHints.username
                ],
                controller: emailCont,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.auth_email,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passCont,
                autofillHints: const [AutofillHints.password],
                obscureText: true,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: AppLocalizations.of(context)!.auth_password),
              ),
              const SizedBox(height: 5),
              signIn ? forgotPassword : const SizedBox(height: 20),
              const SizedBox(height: 5),
              if (errorMsg != null)
                Text(
                  errorMsg!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 5),
              CustomAuthButton(
                onPressed: () {
                  signIn
                      ? runAuth(() => ref
                          .read(authProvider)
                          .signInWithEmailAndPassword(
                              emailCont.text, passCont.text))
                      : runAuth(() => ref
                          .read(authProvider)
                          .signUpWithEmailAndPassword(
                              emailCont.text, passCont.text));
                },
                text: signIn
                    ? AppLocalizations.of(context)!.auth_sign_in
                    : AppLocalizations.of(context)!.auth_sign_up,
              ),
              ConstrainedBox(constraints: const BoxConstraints(maxHeight: 15)),
              oAuthDivider(),
              ConstrainedBox(constraints: const BoxConstraints(maxHeight: 15)),
              OAuthButtons(ref.read(authProvider)),
              const SizedBox(height: 25),
              TextButton(
                onPressed: () {
                  setState(() {
                    signIn = !signIn;
                  });
                },
                child: Text(
                  signIn
                      ? AppLocalizations.of(context)!.auth_sign_up_link
                      : AppLocalizations.of(context)!.auth_sign_in_link,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
