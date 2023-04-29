import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly_app/app/user/data/user_model.dart';
import 'package:poly_app/auth/logic/auth_provider.dart';

final userProvider = ChangeNotifierProvider<UserProvider>(
    (ref) => UserProvider(ref.watch(authStateChangesProvider).value));

final uidProvider = Provider<String?>((ref) {
  return ref.watch(userProvider.select((u) => u.user?.uid));
});

class UserProvider extends ChangeNotifier {
  final User? _fbUser;

  UserState _state = UserState.loading;
  UserModel? _currentU;
  UserModel? get user => _currentU;

  UserProvider(this._fbUser) {
    if (_fbUser != null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(_fbUser!.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          _state = UserState.loaded;
          _currentU = UserModel.fromMap(_fbUser!.uid, doc.data()!);
        } else {
          _state = UserState.onboarding;
        }
        notifyListeners();
      });
    }
  }

  UserState get state => _state;

  Future<void> setUserModel(UserModel newU) async {
    _currentU = newU;
    _state = UserState.loaded;
    notifyListeners();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_fbUser!.uid)
        .set(newU.toMap());
  }
}

enum UserState {
  loading,
  loaded,
  onboarding,
}
