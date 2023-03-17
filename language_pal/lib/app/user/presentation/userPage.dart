import 'package:flutter/material.dart';
import 'package:language_pal/app/iap/presentation/select_offer.dart';
import 'package:language_pal/app/user/userProvider.dart';
import 'package:language_pal/auth/authProvider.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, up, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Email: ${up.u?.email}"),
          Text("Name: ${up.u?.name}"),
          if (up.u?.email != null)
            FilledButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SelectOfferPage()));
                },
                child: const Text("Become Premium Member")),
          TextButton(
            onPressed: () {
              AuthProvider ap = Provider.of(context, listen: false);
              ap.signOut();
            },
            child: const Text("Sign Out"),
          ),
        ],
      );
    });
  }
}
