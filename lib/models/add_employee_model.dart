// lib/models/employee.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class AddEmployeeModel {
  final String name;
  final String email;
  final String role;
  final String avatarUrl;
  final String status;
  final bool emailVerified;

  AddEmployeeModel({
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    this.status = 'pending',
    this.emailVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'username': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'avatarBase64': '',
      'status': status,
      'emailVerified': emailVerified,
      'lastActive': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class EmployeeFormState {
  final bool isLoading;
  final String? errorMessage;
  final File? selectedImage;

  EmployeeFormState({
    required this.isLoading,
    this.errorMessage,
    this.selectedImage,
  });

  EmployeeFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    File? selectedImage,
  }) {
    return EmployeeFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }

  static EmployeeFormState get initial => EmployeeFormState(isLoading: false);
}
