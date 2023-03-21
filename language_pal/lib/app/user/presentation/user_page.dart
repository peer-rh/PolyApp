import 'package:flutter/material.dart';
import 'package:language_pal/app/iap/presentation/select_offer.dart';
import 'package:language_pal/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    AuthProvider ap = context.watch();
    return Scaffold(
      appBar: AppBar(
        title: const Text("User"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Email: ${ap.user?.email}"),
          Text("Name: ${ap.user?.name}"),
          if (ap.user?.email != null)
            FilledButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SelectOfferPage()));
                },
                child: const Text("Become Premium Member")),
          TextButton(
            onPressed: () {
              AuthProvider ap = Provider.of(context, listen: false);
              ap.signOut();
              Navigator.pop(context);
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }
}
