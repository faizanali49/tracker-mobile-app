import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackermobile/views/home/employee_model/fetch_employee_model.dart';

class EmployeeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Employee>> fetchEmployees() async {
    try {
      final companyId = _auth.currentUser!.uid;
      final snapshot = await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .get();

      final employees = snapshot.docs
          .map((doc) => Employee.fromFirestore(doc))
          .toList();

      print("Fetched ${employees.length} employees");
      return employees;
    } catch (e) {
      print("Error fetching employees: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchCompanyData() async {
    try {
      final uid = _auth.currentUser!.uid;
      final doc = await _firestore.collection('companies').doc(uid).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching company data: $e");
      return null;
    }
  }
}
