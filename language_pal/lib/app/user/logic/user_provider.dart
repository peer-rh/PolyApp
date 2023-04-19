import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_pal/app/user/data/user_model.dart';
import 'package:language_pal/auth/logic/auth_provider.dart';

final userProvider = Provider<UserProvider>(
    (ref) => UserProvider(ref.watch(authStateChangesProvider).value));

class UserProvider {
  final User? _fbUser;

  UserState _state = UserState.loading;
  UserModel? _currentU;

  UserProvider(this._fbUser) {
    if (_fbUser != null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(_fbUser!.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          _state = UserState.loaded;
          _currentU = UserModel.fromMap(doc.data()!);
        } else {
          _state = UserState.onboarding;
        }
      });
    }
  }

  UserModel? get user => _currentU;
  UserState get state => _state;

  Future<void> setUserModel(UserModel newU) async {
    _currentU = newU;
    _state = UserState.loaded;
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
