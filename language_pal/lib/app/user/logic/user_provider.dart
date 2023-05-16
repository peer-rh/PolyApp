import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/user/data/user_model.dart';
import 'package:poly_app/auth/logic/auth_provider.dart';

final userProvider = StateNotifierProvider<UserProvider, UserModel?>(
    (ref) => UserProvider(ref.watch(authStateChangesProvider).value));

final uidProvider = Provider<String?>((ref) {
  return ref.watch(userProvider.select((u) => u?.uid));
});

class UserProvider extends StateNotifier<UserModel?> {
  UserProvider(User? fbUser) : super(null) {
    if (fbUser != null) {
      _loadUser(fbUser);
    }
  }

  void _loadUser(User fbUser) async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(fbUser.uid)
        .get();
    if (doc.exists) {
      state = UserModel.fromMap(fbUser.uid, doc.data()!);
    } else {
      state = UserModel(fbUser.uid, fbUser.email ?? "", []);
    }
  }

  void setUser(UserModel? user) {
    state = user;
    if (user != null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set(user.toMap());
    }
  }
}
