// Sign in Button with option for google, apple and default
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:language_pal/auth/auth_provider.dart';

class OAuthButtons extends StatelessWidget {
  final AuthProvider authProvider;

  const OAuthButtons(this.authProvider, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton.icon(
          style: const ButtonStyle(
              minimumSize: MaterialStatePropertyAll(Size.fromHeight(40))),
          onPressed: authProvider.signInWithGoogle,
          icon: const Icon(FontAwesomeIcons.google),
          label: const Text("Sign in with Google"),
        ),
        FilledButton.icon(
          style: const ButtonStyle(
              minimumSize: MaterialStatePropertyAll(Size.fromHeight(40))),
          onPressed: authProvider.signInWithApple,
          icon: const Icon(Icons.apple),
          label: const Text("Sign in with Apple"),
        ),
      ],
    );
  }
}
