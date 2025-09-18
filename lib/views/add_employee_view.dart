// lib/screens/add_employee_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackermobile/providers/add_employee_provider.dart';
import 'package:trackermobile/themes/buttons.dart';
import 'package:trackermobile/themes/colors.dart';
import 'package:trackermobile/themes/textfields.dart';

class AddEmployeeScreen extends ConsumerWidget {
  const AddEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = ref.watch(nameControllerProvider);
    final roleController = ref.watch(roleControllerProvider);
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final uploadedFile = ref.watch(uploadedFileProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final formKey = ref.watch(formKeyProvider);

    return Scaffold(
      key: ref.read(navigatorKeyProvider),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add Employee"),
        backgroundColor: primaryColor,
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
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: nameController,
                      labelText: 'Full Name',
                      prefixIcon: Icons.person,
                      validator: (value) =>
                          value!.isEmpty ? "Please enter a name" : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: roleController,
                      labelText: 'Role',
                      prefixIcon: Icons.work,
                      validator: (value) =>
                          value!.isEmpty ? "Please enter a role" : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: emailController,
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
                      controller: passwordController,
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
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Upload Image"),
                            content: const Text("Choose image source"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  pickImage(ref, ImageSource.gallery);
                                },
                                child: const Text("Gallery"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  pickImage(ref, ImageSource.camera);
                                },
                                child: const Text("Camera"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                            ],
                          ),
                        );
                      },
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
                        child: uploadedFile == null
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
                                  uploadedFile,
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
                        onTap: isLoading ? null : ref.read(submitFormProvider),
                        child: isLoading
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
