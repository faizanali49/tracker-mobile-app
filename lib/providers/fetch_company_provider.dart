import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackermobile/models/fetch_employee_model.dart';
import 'package:trackermobile/services/fetch_company_service.dart';

final employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService();
});

// Change to StreamProvider for real-time updates
// final employeesProvider = StreamProvider<List<Employee>>((ref) {
//   final employeeService = ref.read(employeeServiceProvider);
//   return employeeService.getEmployeesStream();
// });


// Keep the company data provider as FutureProvider
final companyDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final employeeService = ref.read(employeeServiceProvider);
  return employeeService.fetchCompanyData();
});