import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EmployeeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> createEmployee({
    required String name,
    required String email,
    required String password,
    required String role,
    File? avatarFile,
  }) async {
    try {
      final adminUser = _auth.currentUser;
      if (adminUser == null) {
        throw Exception('Admin not signed in.');
      }

      final companyId = adminUser.uid;

      // Check if employee with the same email/username already exists
      final existing = await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .where('username', isEqualTo: email)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('An employee with this email already exists.');
      }

      // Upload avatar to Firebase Storage
      String avatarUrl = '';
      Reference? avatarRef;

      if (avatarFile != null) {
        final fileName =
            'avatar_${DateTime.now().millisecondsSinceEpoch}_${email.split('@')[0]}.jpg';

        avatarRef = _storage
            .ref()
            .child('companies')
            .child(companyId)
            .child('employee_avatars')
            .child(fileName);

        await avatarRef.putFile(avatarFile);
        avatarUrl = await avatarRef.getDownloadURL();
      }

      // Create Firebase Auth user for employee
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUid = userCredential.user?.uid;
      if (newUid == null) {
        throw Exception('Failed to create employee account.');
      }

      // Send verification email
      await userCredential.user?.sendEmailVerification();

      // Add employee to Firestore
      final employeeData = {
        'name': name,
        'email': email,
        'username': email,
        'role': role,
        'avatarUrl': avatarUrl,
        'avatarBase64': '',
        'status': 'pending',
        'emailVerified': false,
        'lastActive': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .doc(newUid)
          .set(employeeData);

      return newUid;
    } catch (error) {
      // Rollback if user was created but something failed after
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email == email) {
        await currentUser.delete();
      }
      print('Error creating employee: $error');
    }
  }
}
