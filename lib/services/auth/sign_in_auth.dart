// lib/views/company_authentication/provider/login_auth.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';

// String sign_companyId = '';


class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Sign in for company users
  Future<User?> signInCompany({
    required String email,
    required String password,
  }) async {
    try {
      // Clear any existing state
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email != email) {
        // If trying to sign in as a different user, sign out first
        await _auth.signOut();
      }

      // Firebase Auth login
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // Check if this user is a company in Firestore
      final companyDoc = await _firestore
          .collection('companies')
          .doc(user.uid)
          .get();

      if (!companyDoc.exists) {
        // ❌ Not a company user - check if it's an employee
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final role = userDoc.get('role');
          if (role == 'employee') {
            // ❌ It's an employee trying to access company app
            await _auth.signOut();
            throw FirebaseAuthException(
              code: 'employee-access-denied',
              message:
                  'Access denied. This account is registered as an employee. Please use the employee portal.',
            );
          }
        }

        // ❌ Not a company or employee user
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'not-company',
          message: 'This account is not registered as a company.',
        );
      }
      // print('Company login successful! CompanyID: ${user.uid}');
      // print('Company name: ${companyDoc.data()?['company'] ?? 'Unknown'}');
      // sign_companyId = user.uid;

      return user; // ✅ Company user found
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
  }
}
