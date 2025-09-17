// lib/services/employee_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import your image compression utility if needed
// import 'package:your_project_name/providers/image_utils_provider.dart';

class EmployeeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> createEmployee({
    required String name,
    required String email, // This will be the username
    required String password,
    required String role,
    File? avatarFile, // Accept the File object directly
  }) async {
    User? adminUser; // To hold the current admin user
    String? companyId;
    String?
    newUid; // To hold the UID of the employee being created (if auth succeeds)
    String? avatarUrl; // To hold the URL if uploaded
    String? avatarBase64Fallback; // Fallback if upload fails
    Reference?
    uploadedAvatarRef; // To hold the storage ref for potential rollback

    try {
      print('Starting employee creation process for: $email');

      // 1. Get current admin user (must be logged in)
      adminUser = _auth.currentUser;
      if (adminUser == null) {
        throw Exception('No admin is currently signed in.');
      }
      companyId = adminUser.uid; // Assuming company ID is the admin's UID
      print('Admin company ID: $companyId');

      // 2. Check for duplicate username/email within the company
      print('Checking for existing employee with email: $email');
      final existingSnapshot = await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .where('username', isEqualTo: email) // Check against username field
          .get();

      if (existingSnapshot.docs.isNotEmpty) {
        print('Duplicate username found: $email');
        throw Exception(
          'Employee with this email/username already exists within your company.',
        );
      }

      // 2. Upload Avatar (if provided) to Storage
      if (avatarFile != null) {
        print('Uploading avatar for employee: $email');
        try {
          // Create a unique filename, perhaps based on email or timestamp
          final fileName =
              'avatar_${DateTime.now().millisecondsSinceEpoch}_${email.split('@')[0]}.jpg';
          final storageRef = _storage
              .ref()
              .child('companies')
              .child(companyId)
              .child('employee_avatars')
              .child(fileName); // Use unique name
          final uploadTask = storageRef.putFile(avatarFile);
          final snapshot = await uploadTask.whenComplete(() {});
          avatarUrl = await snapshot.ref.getDownloadURL();
          uploadedAvatarRef = storageRef; // Keep ref for potential rollback
          print('Avatar uploaded successfully. URL: $avatarUrl');
        } catch (storageError) {
          print('Storage upload failed: $storageError');
        }
      }

      // 3. Prepare employee data
      final employeeData = {
        'name': name,
        'role': role,
        'username': email, // Store email as username
        'email': email, // Store email separately if needed
        'avatarUrl': avatarUrl ?? '',
        'avatarBase64':
            avatarBase64Fallback ?? '', // Store base64 fallback if used
        'status': 'pending', // Or 'unverified'
        'emailVerified': false,
        'lastActive': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        // Add other fields as needed
      };
      print('Prepared employee data.');

      // 4. Attempt to Create Firebase Auth User
      print('Creating Firebase Auth user for: $email');
      UserCredential newUserCredential;
      try {
        newUserCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        newUid = newUserCredential.user?.uid;
        print('Firebase Auth user created successfully. UID: $newUid');

        // 5. Send email verification (optional, can be done after)
        try {
          if (newUserCredential.user != null) {
            await newUserCredential.user!.sendEmailVerification();
            print('Verification email sent to: $email');
          }
        } catch (verificationError) {
          print(
            'Warning: Failed to send verification email: $verificationError',
          );
          // Don't fail the whole process if email sending fails
        }
      } catch (authError) {
        print('Firebase Auth creation failed: $authError');
        // If Auth fails, we haven't written to Firestore yet, so no rollback needed for Firestore.
        // If avatar was uploaded, it's orphaned in Storage, but that's acceptable risk or handled by cleanup jobs.
        rethrow; // Propagate the auth error
      }

      // 6. If Auth Succeeded, Write to Firestore
      if (newUid != null) {
        print('Writing employee data to Firestore for UID: $newUid');
        try {
          // Use the Auth UID as the document ID for consistency
          await _firestore
              .collection('companies')
              .doc(companyId)
              .collection('employees')
              .doc(newUid) // Use Auth UID as doc ID
              .set(employeeData);
          print('Employee data written to Firestore successfully.');

          // 7. Success! Return the new UID
          print(
            'Employee creation process completed successfully for UID: $newUid',
          );
          return newUid;
        } catch (firestoreError) {
          print('Firestore write failed after Auth success: $firestoreError');
          // --- Rollback: Delete the newly created Auth user ---
          try {
            print('Attempting rollback: Deleting Auth user UID: $newUid');
            await newUserCredential.user?.delete();
            print('Rollback successful: Auth user deleted.');
          } catch (rollbackError) {
            print(
              'Warning: Rollback (deleting Auth user) failed: $rollbackError',
            );
            // Log this error for admin/dev attention, but don't stop the main error propagation
            // The Auth user might be orphaned.
          }

          // --- Rollback: Delete the uploaded avatar (if any) ---
          if (uploadedAvatarRef != null) {
            try {
              print('Attempting rollback: Deleting uploaded avatar.');
              await uploadedAvatarRef.delete();
              print('Rollback successful: Uploaded avatar deleted.');
            } catch (storageDeleteError) {
              print(
                'Warning: Rollback (deleting avatar) failed: $storageDeleteError',
              );
              // Avatar might be orphaned in Storage.
            }
          }

          // Re-throw the original Firestore error to indicate failure
          rethrow;
        }
      } else {
        // This shouldn't happen if auth succeeded, but good to check
        print('Error: Auth succeeded but UID is null.');
        throw Exception('Failed to retrieve UID after creating Auth user.');
      }
    } catch (e) {
      print('Error creating employee: $e');

      rethrow; // Propagate the error to the UI
    }
  }
}
