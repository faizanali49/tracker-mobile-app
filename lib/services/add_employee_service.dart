import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class AddEmployeeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>> addEmployee({
    required String name,
    required String email,
    required String role,
    required String password,
    File? avatarFile,
  }) async {
    try {
      // ➡️ FIX: Use the currently authenticated company's email as the companyId.
      final companyId = _auth.currentUser?.email?.toLowerCase();
      if (companyId == null) {
        return {
          'success': false,
          'message': 'Company not authenticated. Please sign in.',
        };
      }

      final employeeEmailKey = email.toLowerCase();

      // 1. Check if an employee with this email already exists in Firestore.
      final docSnapshot = await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .doc(employeeEmailKey)
          .get();

      if (docSnapshot.exists) {
        return {
          'success': false,
          'message': 'An employee with this email already exists.',
        };
      }

      // 2. Upload avatar or use a default URL.
      String avatarUrl = '';
      if (avatarFile != null) {
        final compressedFile = await _compressImage(avatarFile);
        avatarUrl = await _uploadImage(compressedFile, companyId, employeeEmailKey);
      } else {
        avatarUrl = _getDefaultAvatarUrl(name);
      }

      // 3. Create the employee authentication account.
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.sendEmailVerification();
      final employeeUid = userCredential.user!.uid;

      // 4. Create the employee data document in Firestore.
      final employeeData = {
        'uid': employeeUid, // Save the new employee's UID
        'name': name,
        'email': employeeEmailKey,
        'role': role,
        'avatarUrl': avatarUrl,
        'status': 'pending',
        'emailVerified': false,
        'lastActive': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .doc(employeeEmailKey)
          .set(employeeData);

      return {
        'success': true,
        'message':
            'Employee created successfully! An invite has been sent to their email.',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The email address is already in use by another account.';
      } else {
        message = 'An authentication error occurred: ${e.message}';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Failed to add employee: $e'};
    }
  }

  Future<File> _compressImage(File imageFile) async {
    return imageFile;
  }

  Future<String> _uploadImage(
    File imageFile,
    String companyId,
    String employeeEmailKey,
  ) async {
    final fileName = '${employeeEmailKey}_${p.extension(imageFile.path)}';
    final storageRef = _storage.ref().child(
      'companies/$companyId/employee_avatars/$fileName',
    );

    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }

  String _getDefaultAvatarUrl(String name) {
    return 'https://ui-avatars.com/api/?name=$name&background=random';
  }
}
