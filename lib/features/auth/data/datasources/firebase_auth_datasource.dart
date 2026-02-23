import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) throw Exception('User is null after sign in');
    return credential.user!;
  }

  Future<User> signUp(String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) throw Exception('User is null after sign up');
    return credential.user!;
  }

  Future<User?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      // 1. Initialize (Firebase handles the Client ID automatically under the hood)
      await googleSignIn.initialize();

      // 2. Authenticate (Throws an exception if the user hits cancel)
      final gUser = await googleSignIn.authenticate();

      // 3. AWAIT the authentication details (this was missing in your snippet!)
      final gAuth = gUser.authentication;

      // 4. Create the Firebase Credential
      final credential = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
      );

      // 5. Sign in to Firebase Auth
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } on Exception catch (e) {
      // EDGE CASE: If the user cancels the popup, v7 throws an exception.
      // We quietly return null so the Cubit knows to just stop the loading spinner.
      debugPrint('Google Sign In cancelled or failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
