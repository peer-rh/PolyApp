import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class AuthException {
  String msg;
  AuthException(this.msg);
}

class AuthProvider with ChangeNotifier {
  User? user;
  StreamSubscription? userAuthSub;

  AuthProvider() {
    userAuthSub = FirebaseAuth.instance.authStateChanges().listen((event) {
      user = event;
      // TODO: Perhaps seperate Logic to own File
      // TODO: Find out if it is necessary to log out
      if (user != null) {
        print(user?.email);
        Purchases.logIn((user as User).uid);
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    if (userAuthSub != null) {
      userAuthSub?.cancel();
      userAuthSub = null;
    }
    super.dispose();
  }

  void signInWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(e.code);
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
      appleProvider.addScope("name");
      await FirebaseAuth.instance.signInWithProvider(appleProvider);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-disabled":
          throw AuthException("This account has been disabled");
        default:
          throw AuthException("Something went wrong. Please try again.");
      }
    }
  }

  void signInAnonymously() {
    FirebaseAuth.instance.signInAnonymously();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
