// lib/providers/add_employee_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackermobile/services/add_employe_service.dart';

// Text Editing Controllers as Providers
final nameControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final roleControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final emailControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final passwordControllerProvider = Provider.autoDispose((ref) => TextEditingController());

// Form key provider
final formKeyProvider = Provider.autoDispose((ref) => GlobalKey<FormState>());

// State Providers
final uploadedFileProvider = StateProvider<File?>((ref) => null);
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Image picking logic
final imagePickerProvider = Provider((ref) => ImagePicker());

Future<void> pickImage(WidgetRef ref, ImageSource source) async {
  final picker = ref.read(imagePickerProvider);
  final pickedFile = await picker.pickImage(source: source);
  if (pickedFile != null) {
    ref.read(uploadedFileProvider.notifier).state = File(pickedFile.path);
  }
}

// Form submission logic
final submitFormProvider = Provider((ref) {
  return () async {
    final formKey = ref.read(formKeyProvider);
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    ref.read(isLoadingProvider.notifier).state = true;

    try {
      // Show confirmation dialog
      final context = ref.read(navigatorKeyProvider).currentContext!;
      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Create Employee"),
          content: const Text("Are you sure you want to create this employee?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      if (confirm != true) {
        ref.read(isLoadingProvider.notifier).state = false;
        return;
      }

      final name = ref.read(nameControllerProvider).text.trim();
      final email = ref.read(emailControllerProvider).text.trim();
      final password = ref.read(passwordControllerProvider).text.trim();
      final role = ref.read(roleControllerProvider).text.trim();
      final file = ref.read(uploadedFileProvider);

      await EmployeeService().createEmployee(
        name: name,
        email: email,
        password: password,
        role: role,
        avatarFile: file,
      );

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Employee created and invite sent. Employee must verify email to activate.'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      ref.read(nameControllerProvider).clear();
      ref.read(roleControllerProvider).clear();
      ref.read(emailControllerProvider).clear();
      ref.read(passwordControllerProvider).clear();
      ref.read(uploadedFileProvider.notifier).state = null;

      Navigator.of(context).pop(true); // Return success

    } catch (e) {
      final context = ref.read(navigatorKeyProvider).currentContext!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  };
});

// Navigator key for showing dialogs/snackbars
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});
