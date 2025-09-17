import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:trackermobile/themes/buttons.dart';
import 'package:trackermobile/themes/textfields.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  final OutlineInputBorder _borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5),
  );

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 600,
        imageQuality: 40,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (await file.exists()) {
          setState(() {
            _selectedImage = file;
          });
        } else {
          _showSnack("Selected image file is invalid or does not exist.");
        }
      }
    } catch (e) {
      _showSnack("Failed to pick image: ${e.toString()}");
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnack("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = FirebaseAuth.instance;

      // ✅ Create account
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // ✅ Upload image to Firebase Storage instead of Base64
      String? photoUrl;
      if (_selectedImage != null && await _selectedImage!.exists()) {
        try {
          // Create a storage reference with company ID and timestamp
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('company_avatars')
              .child('$uid.jpg');

          // Show upload progress (optional)
          final uploadTask = storageRef.putFile(_selectedImage!);
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
          });

          // Wait for upload to complete
          await uploadTask.whenComplete(() => print('Upload complete'));

          // Get download URL
          photoUrl = await storageRef.getDownloadURL();
          print('Image uploaded. URL: $photoUrl');
        } catch (e) {
          print('Error uploading image: $e');
          _showSnack('Profile image upload failed, but account was created');
        }
      }

      // ✅ Save profile to Firestore with image URL instead of Base64
      await FirebaseFirestore.instance.collection('companies').doc(uid).set({
        'uid': uid,
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
        'company': _companyController.text.trim(),
        'avatarUrl': photoUrl ?? '', // Store URL instead of Base64
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ Send verification email
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        _showSnack('Verification email sent. Please check your inbox.');
      }

      if (mounted) context.go('/home');
    } catch (e) {
      _showSnack('Signup failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Title
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// Profile Picture Upload
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          child: _selectedImage != null
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundImage: FileImage(_selectedImage!),
                                )
                              : Icon(
                                  PhosphorIcons.user(),
                                  size: 50,
                                  color: Colors.grey.shade500,
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Email Field
                      CustomTextField(
                        controller: _usernameController,
                        labelText: 'Username',
                        prefixIcon: PhosphorIcons.user(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your Username";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        prefixIcon: PhosphorIcons.at(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your Email";
                          }
                          if (!value.contains('@')) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _companyController,
                        labelText: 'Company Name',
                        prefixIcon: PhosphorIcons.identificationBadge(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your Company Name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        prefixIcon: PhosphorIcons.password(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        prefixIcon: PhosphorIcons.repeat(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm your password";
                          }
                          return null;
                        },
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),

                      /// Signup Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: InkWell(
                          onTap: _isLoading ? null : _submitForm,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomBtns(text: "Sign Up"),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go('/login');
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
