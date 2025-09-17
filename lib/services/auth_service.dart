import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen to auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Optionally send email verification
    if (!cred.user!.emailVerified) {
      await cred.user!.sendEmailVerification();
    }
    return cred;
  }

  // Sign in
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred;
  }

  // Send password reset
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Sign out
  Future<void> signOut() async => _auth.signOut();

  // Current user
  User? get currentUser => _auth.currentUser;
}
