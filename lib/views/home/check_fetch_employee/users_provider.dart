// // providers/employee_provider.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trackermobile/models/fetch_employee_model.dart';

// // Use a FutureProvider.family to pass the companyId.
// final employeeListProvider = FutureProvider.family
//     .autoDispose<List<Employee>, String>((ref, companyId) async {
//       // Access the Firestore instance and fetch the nested subcollection.
//       final snapshot = await FirebaseFirestore.instance
//           .collection('companies')
//           .doc(companyId)
//           .collection('employees')
//           .get();

//       // Map the snapshots to a list of Employee objects.
//       return snapshot.docs.map((doc) => Employee.fromFirestore(doc)).toList();
//     });
