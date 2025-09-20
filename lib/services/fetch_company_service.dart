import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackermobile/models/fetch_employee_model.dart';

class EmployeeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  

  // Future<List<Employee>> fetchEmployees() async {
  //   try {
  //     final String companyId = _auth.currentUser!.email!.toLowerCase();
  //     final snapshot = await _firestore
  //         .collection('companies')
  //         .doc(companyId)
  //         .collection('employees')
  //         .get();

  //     final employees = snapshot.docs
  //         .map((doc) => Employee.fromFirestore(doc))
  //         .toList();

  //     print("Fetched ${employees.length} employees");
  //     return employees;
  //   } catch (e) {
  //     print("Error fetching employees: $e");
  //     rethrow;
  //   }
  // }

  // Get a stream of all employees
  // Stream<List<Employee>> getEmployeesStream() {
  //   final companyId = _auth.currentUser!.email!.toLowerCase();
  //   return _firestore
  //       .collection('companies')
  //       .doc(companyId)
  //       .collection('employees')
  //       .snapshots()
  //       .map(
  //         (snapshot) =>
  //             snapshot.docs.map((doc) => Employee.fromFirestore(doc)).toList(),
  //       );
  // }

  Future<Map<String, dynamic>?> fetchCompanyData() async {
    try {
      final companyId = _auth.currentUser!.email!.toLowerCase();
      final doc = await _firestore.collection('companies').doc(companyId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching company data: $e");
      rethrow;
    }
  }
}
