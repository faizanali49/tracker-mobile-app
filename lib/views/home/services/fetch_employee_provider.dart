// // lib/providers/fetch_employees_function_provider.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:trackermobile/views/home/employee_model/fetch_employee_model.dart';

// final fetchEmployeesFunctionProvider = Provider<Future<List<Employee>> Function()>((ref) {
//   return () async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) throw Exception("Not logged in");

//     final snapshot = await FirebaseFirestore.instance
//         .collection('companies')
//         .doc(user.uid)
//         .collection('employees')
//         .get();

//     return snapshot.docs.map((doc) => Employee.fromFirestore(doc)).toList();
//   };
// });
