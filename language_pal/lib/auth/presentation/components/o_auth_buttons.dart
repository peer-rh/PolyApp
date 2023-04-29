// Sign in Button with option for google, apple and default
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:poly_app/auth/logic/auth_provider.dart';

class OAuthButtons extends StatelessWidget {
  final AuthProvider authProvider;

  const OAuthButtons(this.authProvider, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            style: ButtonStyle(
                side: MaterialStateProperty.all(
                    BorderSide(color: Theme.of(context).primaryColor))),
            onPressed: authProvider.signInWithGoogle,
            icon: const Icon(FontAwesomeIcons.google)),
        IconButton(
          style: ButtonStyle(
              side: MaterialStateProperty.all(
                  BorderSide(color: Theme.of(context).primaryColor))),
          onPressed: authProvider.signInWithApple,
          icon: const Icon(Icons.apple),
        ),
      ],
    );
  }
}

Widget oAuthDivider() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Expanded(
        child: Divider(),
      ),
      SizedBox(
        width: 10,
      ),
      Text("OR"),
      SizedBox(
        width: 10,
      ),
      Expanded(
        child: Divider(),
      ),
    ],
  );
}
