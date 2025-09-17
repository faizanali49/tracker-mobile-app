// lib/screens/add_employee_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackermobile/themes/buttons.dart';
import 'package:trackermobile/themes/colors.dart';
import 'package:trackermobile/themes/textfields.dart';
import 'package:trackermobile/views/company_authentication/provider/login_auth.dart';
import 'package:trackermobile/views/company_authentication/service/add_employe_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEmployeeScreen extends ConsumerStatefulWidget {
  final String user;
  const AddEmployeeScreen({super.key, this.user = ''});

  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends ConsumerState<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();

  File? _uploadedFile;
  bool _isLoading = false;
  bool _mounted = true;

  // Pick image
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null && _mounted) {
      setState(() {
        _uploadedFile = File(pickedFile.path);
      });
    }
  }

  // Show confirmation dialog
  Future<bool> _confirmEmployeeCreation() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Create Employee"),
        content: const Text("Are you sure you want to create this employee?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // Submit form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_mounted) return;
    setState(() => _isLoading = true);

    try {
      // Show confirmation dialog
      final confirmed = await _confirmEmployeeCreation();
      if (!confirmed) {
        setState(() => _isLoading = false);
        return;
      }

      // Create employee using the service
      final employeeService = EmployeeService();
      await employeeService.createEmployee(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _roleController.text.trim(),
        avatarFile: _uploadedFile,
      );

      // Success message
      if (!_mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ Employee created and invite sent. Employee must verify email to activate.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      _nameController.clear();
      _roleController.clear();
      _emailController.clear();
      _passwordController.clear();
      if (_mounted) {
        setState(() => _uploadedFile = null);
      }
    } catch (e) {
      if (!_mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (_mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Image picker dialog
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Upload Image"),
        content: const Text("Choose image source"),
        actions: [
          TextButton(
            child: const Text("Gallery"),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          TextButton(
            child: const Text("Camera"),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _mounted = true;

    // Check authentication status
    Future.microtask(() {
      if (FirebaseAuth.instance.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to add employees'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userrole = ref.read(usernameProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add Employee $userrole"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Stack(
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      prefixIcon: Icons.person,
                      validator: (value) =>
                          value!.isEmpty ? "Please enter a name" : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _roleController,
                      labelText: 'Role',
                      prefixIcon: Icons.work,
                      validator: (value) =>
                          value!.isEmpty ? "Please enter a role" : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      validator: (value) {
                        if (value!.isEmpty) return "Please enter a password";
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 24),
                    const Text(
                      "Picture Upload",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showImagePickerDialog,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade700,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child: _uploadedFile == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload,
                                      color: Colors.grey.shade700,
                                      size: 36,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Tap to upload",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _uploadedFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text('❌ Image load failed'),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: InkWell(
                        onTap: _isLoading ? null : _submitForm,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : CustomBtns(text: 'Add Employee'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
