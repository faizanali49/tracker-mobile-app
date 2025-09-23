import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart' as p;

class AddEmployeeService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // main auth (company)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create a separate FirebaseAuth instance for employee creation
  Future<FirebaseAuth> _getEmployeeAuth() async {
    final app = await Firebase.initializeApp(
      name: 'employeeApp',
      options: Firebase.app().options, // reuse default app options
    );
    return FirebaseAuth.instanceFor(app: app);
  }

  Future<Map<String, dynamic>> addEmployee({
    required String name,
    required String email,
    required String role,
    required String password,
    File? avatarFile,
  }) async {
    final companyUser = _auth.currentUser;
    final companyEmailId = companyUser?.email?.toLowerCase();

    if (companyEmailId == null) {
      return {
        'success': false,
        'message': 'Company not authenticated. Please sign in.',
      };
    }

    final employeeEmailKey = email.toLowerCase();

    try {
      // 1. Prevent duplicate
      final docRef = _firestore
          .collection('companies')
          .doc(companyEmailId)
          .collection('employees')
          .doc(employeeEmailKey);

      if ((await docRef.get()).exists) {
        return {
          'success': false,
          'message': 'An employee with this email already exists.',
        };
      }

      // 2. Upload avatar or fallback
      final avatarUrl = avatarFile != null
          ? await _uploadImage(avatarFile, companyEmailId, employeeEmailKey)
          : _getDefaultAvatarUrl(name);

      // 3. Create Firestore record
      final employeeData = {
        'name': name,
        'email': employeeEmailKey,
        'role': role,
        'avatarUrl': avatarUrl,
        'status': 'offline',
        'emailVerified': false,
        'lastActive': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(employeeData);

      // 4. Create Auth account
      final employeeAuth = await _getEmployeeAuth();
      try {
        await employeeAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (authError) {
        // rollback Firestore if Auth fails
        await docRef.delete();
        rethrow;
      } finally {
        await employeeAuth.signOut();
      }

      return {'success': true, 'message': 'Employee created successfully!'};
    } catch (e) {
      return {
        'success': false,
        'message': e is FirebaseAuthException
            ? (e.code == 'weak-password'
                  ? 'The password provided is too weak.'
                  : e.code == 'email-already-in-use'
                  ? 'The email address is already in use.'
                  : 'Auth error: ${e.message}')
            : 'Failed to add employee: $e',
      };
    }
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
    final snapshot = await storageRef.putFile(imageFile);
    return await snapshot.ref.getDownloadURL();
  }

  String _getDefaultAvatarUrl(String name) {
    return 'https://ui-avatars.com/api/?name=$name&background=random';
  }
}
