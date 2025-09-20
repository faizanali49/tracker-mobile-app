import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<User?> signInCompany({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Authenticate the user with Firebase.
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found.',
        );
      }

      // 2. Check if a company document exists for this email.
      final companyDoc =
          await _firestore.collection('companies').doc(user.email).get();

      // 3. If the document does not exist, sign the user out and throw an error.
      if (!companyDoc.exists) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'not-a-company',
          message:
              'This email is not registered as a company. Please use a company account to sign in.',
        );
      }

      // 4. If the document exists, return the user.
      return user;
    } on FirebaseAuthException catch (e) {
      // Catch specific Firebase Auth exceptions and re-throw with a custom message.
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw Exception('Invalid email or password.');
      } else {
        throw Exception(e.message ?? 'An unknown authentication error occurred.');
      }
    } catch (e) {
      // Catch any other exceptions.
      throw Exception('An unexpected error occurred during sign in.');
    }
  }
}
