import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/learn_track/logic/user_progress_provider.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/auth/logic/auth_provider.dart';
import 'package:poly_app/common/ui/custom_icons.dart';
import 'package:poly_app/common/ui/custom_nav_item.dart';
import 'package:poly_app/common/ui/frosted_app_bar.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final up = ref.read(userProvider);
    return Scaffold(
        appBar: const FrostedAppBar(
          title: Text("Account"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.surface, width: 1),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.primary),
                        height: 24,
                        width: 24,
                        child: Icon(CustomIcons.accout,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary)),
                    const SizedBox(width: 8),
                    Text(up!.email,
                        style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomNavListItem(
                  onTap: () {
                    ref.read(authProvider).signOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  enabled: true,
                  title: Text("Log Out",
                      style: Theme.of(context).textTheme.titleSmall),
                  icon: Icons.logout),
              const SizedBox(height: 24),
              CustomNavListItem(
                  onTap: () {
                    Widget cancelButton = TextButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    );
                    Widget continueButton = FilledButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                      ),
                      child: const Text("Confirm"),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(up.uid)
                            .delete();
                        try {
                          ref.read(authProvider).deleteAccount();
                        } catch (e) {
                          // TODO: Relinlk to recent sign in
                        }
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                    );

                    // Create the dialog
                    AlertDialog alert = AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      title: const Text("Delete Account?"),
                      content: const Text(
                          "Are you sure you want to delete your account? This action cannot be undone."),
                      actions: [
                        cancelButton,
                        continueButton,
                      ],
                    );

                    // Show the dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => alert,
                    );
                  },
                  enabled: true,
                  highlighted: true,
                  title: Text("Delete Account",
                      style: Theme.of(context).textTheme.titleSmall),
                  icon: Icons.delete),
            ],
          ),
        ));
  }
}
