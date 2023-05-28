import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:poly_app/auth/data/auth_exception.dart';

final authProvider = Provider<AuthProvider>((ref) => AuthProvider());

final authStateChangesProvider =
    StreamProvider<User?>((ref) => ref.watch(authProvider).authStateChanges);

class AuthProvider {
  final _fb = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _fb.authStateChanges();
  User? get currentUser => _fb.currentUser;

  void signInWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    }
  }

  void signUpWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    }
  }

  void forgotPassword(String email) async {
    // TODO: Success Feedback
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
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
      throw AuthException.fromCode(e.code);
    }
  }

  void signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope("email");
      await FirebaseAuth.instance.signInWithProvider(appleProvider);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void deleteAccount() async {
    // TODO: Handle error
    await FirebaseAuth.instance.currentUser?.delete();
  }
}
