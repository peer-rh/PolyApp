import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/auth/data/auth_exception.dart';
import 'package:poly_app/auth/logic/auth_provider.dart';
import 'package:poly_app/auth/presentation/components/o_auth_buttons.dart';
import 'package:poly_app/auth/presentation/forgot_password.dart';
import 'package:poly_app/common/ui/divider.dart';
import 'package:poly_app/common/ui/logo.dart';
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
          style: const TextStyle(
            fontSize: 12,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Logo(80),
            const SizedBox(height: 64),
            TextField(
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [
                AutofillHints.email,
                AutofillHints.username
              ],
              controller: emailCont,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                labelText: AppLocalizations.of(context)!.auth_email,
                labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.6),
                    ),
                floatingLabelStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCont,
              autofillHints: const [AutofillHints.password],
              obscureText: true,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                labelText: AppLocalizations.of(context)!.auth_password,
                labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.6),
                    ),
                floatingLabelStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: 8),
            signIn ? forgotPassword : const SizedBox(height: 17),
            const SizedBox(height: 4),
            if (errorMsg != null)
              Text(
                errorMsg!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 8),
            FilledButton(
              style: ButtonStyle(
                minimumSize:
                    MaterialStateProperty.all(const Size.fromHeight(48)),
              ),
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
              child: Text(
                signIn
                    ? AppLocalizations.of(context)!.auth_sign_in
                    : AppLocalizations.of(context)!.auth_sign_up,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            CustomDivider(text: "OR"), // TODO: i18n
            const SizedBox(height: 16),
            OAuthButtons(ref.read(authProvider)),
            const SizedBox(height: 96),
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
    );
  }
}
