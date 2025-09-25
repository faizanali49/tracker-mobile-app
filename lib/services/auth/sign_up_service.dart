import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class SignupAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final logger = Logger();

  Future<File?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 600,
        imageQuality: 40,
      );
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (_) {
      rethrow;
    }
  }

  Future<String?> uploadImage(String uid, File imageFile) async {
    try {
      final storageRef = _storage.ref().child('company_avatars/$uid.jpg');
      final uploadTask = storageRef.putFile(imageFile);
      await uploadTask.whenComplete(() {});
      return await storageRef.getDownloadURL();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String username,
    required String company,
    File? imageFile,
  }) async {
    final companyEmail = email.trim().toLowerCase();

    // Check Firestore for existing company email before creating the Auth user.
    final companyDoc = await _firestore
        .collection('companies')
        .doc(companyEmail)
        .get();

    if (companyDoc.exists) {
      logger.w('Company with email $companyEmail already exists.');
    }

    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: companyEmail,
      password: password.trim(),
    );
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      logger.i('Verification email sent to ${user.email}');
    }

    final uid = userCredential.user!.uid;

    String? photoUrl;
    if (imageFile != null) {
      photoUrl = await uploadImage(uid, imageFile);
    }

    // Use the company's email as the document ID.
    await _firestore.collection('companies').doc(companyEmail).set({
      'uid': uid,
      'email': companyEmail,
      'username': username.trim(),
      'company': company.trim(),
      'avatarUrl': photoUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!userCredential.user!.emailVerified) {
      await userCredential.user!.sendEmailVerification();
    }
  }
}
