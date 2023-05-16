import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/user/logic/user_provider.dart';
import 'package:poly_app/auth/logic/auth_provider.dart';

class UserPage extends ConsumerStatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  @override
  Widget build(BuildContext context) {
    final userP = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("User"),
      ),
      body: userP == null
          ? Container()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_circle_outlined,
                          size: 54, fill: 0.0),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(userP.email,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () {
                          ref.read(authProvider).signOut();
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
