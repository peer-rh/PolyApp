// Sign in Button with option for google, apple and default
import 'package:flutter/material.dart';
import 'package:poly_app/auth/logic/auth_provider.dart';
import 'package:poly_app/common/ui/custom_circular_button.dart';
import 'package:poly_app/common/ui/custom_icons.dart';

class OAuthButtons extends StatelessWidget {
  final AuthProvider authProvider;

  const OAuthButtons(this.authProvider, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomCircularButton(
            size: 48,
            icon: const Icon(CustomIcons.apple),
            outlineColor: Theme.of(context).colorScheme.onBackground,
            onPressed: authProvider.signInWithApple),
        const SizedBox(
          width: 16,
        ),
        CustomCircularButton(
            size: 48,
            icon: const Icon(CustomIcons.google),
            outlineColor: Theme.of(context).colorScheme.onBackground,
            onPressed: authProvider.signInWithGoogle),
      ],
    );
  }
}
