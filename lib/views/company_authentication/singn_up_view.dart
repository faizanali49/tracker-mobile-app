import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:trackermobile/services/auth/sign_up_service.dart';
import 'package:trackermobile/themes/buttons.dart';
import 'package:trackermobile/themes/textfields.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _authService = SignupAuthService();

  File? _selectedImage;
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final image = await _authService.pickImage();
      if (image != null && await image.exists()) {
        setState(() => _selectedImage = image);
      } else {
        _showSnack("Selected image is invalid or doesn't exist.");
      }
    } catch (e) {
      _showSnack("Failed to pick image: $e");
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
      await _authService.registerUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        company: _companyController.text,
        imageFile: _selectedImage,
      );

      _showSnack("Account is created. Verification email sent.");
      if (mounted) context.go('/login');
    } catch (e) {
      _showSnack("Signup failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

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

                      CustomTextField(
                        controller: _usernameController,
                        labelText: 'Username',
                        prefixIcon: PhosphorIcons.user(),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter your username'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        prefixIcon: PhosphorIcons.at(),
                        validator: (val) => val == null || !val.contains('@')
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: _companyController,
                        labelText: 'Company Name',
                        prefixIcon: PhosphorIcons.identificationBadge(),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter company name'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        prefixIcon: PhosphorIcons.password(),
                        isPassword: true,
                        validator: (val) => val == null || val.length < 6
                            ? 'Min 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        prefixIcon: PhosphorIcons.repeat(),
                        isPassword: true,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Confirm your password'
                            : null,
                      ),
                      const SizedBox(height: 30),

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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text(
                              "Login",
                              style: TextStyle(color: Colors.blue),
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
