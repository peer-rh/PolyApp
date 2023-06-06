import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/auth/data/auth_exception.dart';
import 'package:poly_app/auth/logic/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
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
        appBar: FrostedAppBar(
          title: Text(AppLocalizations.of(context)!.forgot_password_title),
        ),
        body: Stack(children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.username
                  ],
                  controller: emailCont,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                const SizedBox(height: 4),
                if (errorMsg != null)
                  Text(
                    errorMsg!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(
                        const Size.fromHeight(48),
                      ),
                    ),
                    onPressed: () {
                      runAuth(() => ref
                          .read(authProvider)
                          .forgotPassword(emailCont.text));
                    },
                    child: Text(
                        AppLocalizations.of(context)!.forgot_password_button)),
              ],
            ),
          ),
        ]));
  }
}
