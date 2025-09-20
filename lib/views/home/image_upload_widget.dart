// lib/widgets/image_picker_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerDialog extends StatelessWidget {
  final Function(File) onImageSelected;

  const ImagePickerDialog({super.key, required this.onImageSelected});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      Navigator.pop(context);
      onImageSelected(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Upload Image"),
      content: const Text("Choose image source"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => _pickImage(context, ImageSource.gallery),
          child: const Text("Gallery"),
        ),
        TextButton(
          onPressed: () => _pickImage(context, ImageSource.camera),
          child: const Text("Camera"),
        ),
      ],
    );
  }
}
