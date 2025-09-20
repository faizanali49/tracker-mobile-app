// lib/providers/employee_provider.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:trackermobile/models/add_employee_model.dart';
import 'package:trackermobile/services/add_employee_service.dart';

// Employee Service Provider
final employeeServiceProvider = Provider<AddEmployeeService>((ref) {
  return AddEmployeeService();
});

// Employee Form State Provider
final employeeFormProvider =
    StateNotifierProvider<EmployeeFormNotifier, EmployeeFormState>((ref) {
      return EmployeeFormNotifier(ref.read(employeeServiceProvider));
    });

// Form State Notifier
class EmployeeFormNotifier extends StateNotifier<EmployeeFormState> {
  final AddEmployeeService _employeeService;

  EmployeeFormNotifier(this._employeeService)
    : super(EmployeeFormState.initial);

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void setImage(File? image) {
    state = state.copyWith(selectedImage: image);
  }

  Future<bool> addEmployee({
    required String name,
    required String email,
    required String role,
    required String password,
  }) async {
    if (state.isLoading) return false;

    setLoading(true);
    clearError();

    try {
      await _employeeService.addEmployee(
        name: name,
        email: email,
        role: role,
        password: password,
        avatarFile: state.selectedImage,
      );
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }
}
