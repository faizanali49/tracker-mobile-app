import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _logger = Logger();

  Future<Map<String, dynamic>> signInCompany({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Authenticate user
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        _logger.w('User not found for $email');
        return {'success': false, 'message': 'Sign in failed, try again.'};
      }

      // 2. Verify company document
      final doc = await _firestore
          .collection('companies')
          .doc(user.email)
          .get();
      if (!doc.exists) {
        await _auth.signOut();
        _logger.w('$email is not a registered company');
        return {'success': false, 'message': 'Sign in failed, try again.'};
      }

      _logger.i('Company sign-in successful: ${user.email}');
      return {'success': true, 'user': user};
    } catch (e, stack) {
      _logger.e('Sign in failed', error: e, stackTrace: stack);
      return {'success': false, 'message': 'Sign in failed, try again.'};
    }
  }
}
