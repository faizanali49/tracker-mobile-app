import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:trackermobile/views/home/employee_model/fetch_employee_model.dart';
import 'package:trackermobile/views/home/services/employee_service.dart';

final employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService();
});

final employeesProvider =
    StateNotifierProvider<EmployeeNotifier, AsyncValue<List<Employee>>>(
      (ref) => EmployeeNotifier(ref.read(employeeServiceProvider)),
    );

class EmployeeNotifier extends StateNotifier<AsyncValue<List<Employee>>> {
  final EmployeeService employeeService;

  EmployeeNotifier(this.employeeService) : super(const AsyncValue.loading()) {
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    state = const AsyncValue.loading();
    try {
      final employees = await employeeService.fetchEmployees();
      state = AsyncValue.data(employees);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void refresh() {
    fetchEmployees();
  }
}

final companyDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final employeeService = ref.read(employeeServiceProvider);
  return employeeService.fetchCompanyData();
});
