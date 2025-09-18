import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class SignupAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = userCredential.user!.uid;

    String? photoUrl;
    if (imageFile != null) {
      photoUrl = await uploadImage(uid, imageFile);
    }

    await _firestore.collection('companies').doc(uid).set({
      'uid': uid,
      'email': email.trim(),
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
