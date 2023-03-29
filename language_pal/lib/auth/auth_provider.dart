import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:language_pal/auth/models/user_model.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class AuthException {
  String msg;
  AuthException(this.msg);
}

enum AuthState {
  loading,
  authenticated,
  unauthenticated,
  onboarding,
}

class AuthProvider with ChangeNotifier {
  User? firebaseUser;
  UserModel? user;
  AuthState state = AuthState.loading;

  StreamSubscription? userAuthSub;

  AuthProvider() {
    userAuthSub = FirebaseAuth.instance.authStateChanges().listen((event) {
      firebaseUser = event;
      if (firebaseUser != null) {
        Purchases.logIn((firebaseUser!).uid);
        _getFirestore();
      } else {
        user = null;
        setState(AuthState.unauthenticated);
      }
      notifyListeners();
    });
  }

  void _getFirestore() async {
    if (firebaseUser == null) {
      return;
    }
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUser!.uid)
        .get();
    if (!doc.exists) {
      setState(AuthState.onboarding);
    } else {
      user = UserModel(
          doc.get("email"),
          doc.get("appLang"),
          doc.get("learnLang"),
          doc.get("useCase"),
          doc.get("scenarioScores").cast<String, int>());
      setState(AuthState.authenticated);
    }
  }

  void setUserModel(UserModel newU) {
    user = newU;
    FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUser!.uid)
        .set(newU.toMap());
    setState(AuthState.authenticated);
    notifyListeners();
  }

  @override
  void dispose() {
    if (userAuthSub != null) {
      userAuthSub?.cancel();
      userAuthSub = null;
    }
    super.dispose();
  }

  void setState(AuthState newState) {
    state = newState;
    notifyListeners();
  }

  void signInWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      setState(AuthState.loading);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          throw AuthException("Please enter a valid Email");
        case "user-disabled":
          throw AuthException("This User has been disabled");
        case "user-not-found":
        case "wrong-password":
          throw AuthException("Email or Password is wrong.");
        default:
          throw AuthException("Something went wrong. Please try again.");
      }
    }
  }

  void signUpWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      setState(AuthState.loading);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          throw AuthException("Email is already in Use");
        case "weak-password":
          throw AuthException("The Password is to weak (min. 6 characters)");
        case "invalid-email":
          throw AuthException("Please enter a valid Email");
        default:
          throw AuthException("Something went wrong. Please try again.");
      }
    }
  }

  void forgotPassword(String email) async {
    // TODO: Success Feedback
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          throw AuthException("Please enter a valid Email");
        case "user-not-found":
          throw AuthException("No User with that Email exists");
        default:
          throw AuthException("Something went wrong. Please try again.");
      }
    }
  }

  void signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(AuthState.loading);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "account-exists-with-different-credentials":
          throw AuthException(
              "There already exists an Account with this Email");
        default:
          throw AuthException("Something went wrong. Please try again.");
      }
    }
  }

  void signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope("email");
      await FirebaseAuth.instance.signInWithProvider(appleProvider);
      setState(AuthState.loading);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-disabled":
          throw AuthException("This account has been disabled");
        default:
          throw AuthException("Something went wrong. Please try again.");
      }
    }
  }

  void signOut() {
    setState(AuthState.loading);
    FirebaseAuth.instance.signOut();
  }
}
