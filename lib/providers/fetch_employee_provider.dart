import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackermobile/models/fetch_employee_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

final employeesStreamProvider =
    StreamProvider.family<List<FetchEmployee>, String>((ref, companyEmailId) {
      final firestore = FirebaseFirestore.instance;
      final employeesCollection = firestore
          .collection('companies')
          .doc(companyEmailId)
          .collection('employees');

      return employeesCollection.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => FetchEmployee.fromFirestore(doc))
            .toList();
      });
    });



// final employeeCurrentStatus =
//     StreamProvider.family<
//       EmployeeStatus?,
//       (String companyEmail, String employeeEmail)
//     >((ref, params) {
//       final (companyEmailId, employeeEmailId) = params;

//       final firestore = FirebaseFirestore.instance;

//       final activitiesQuery = firestore
//           .collection('companies')
//           .doc(companyEmailId)
//           .collection('employees')
//           .doc(employeeEmailId)
//           .collection('activities')
//           .orderBy('timestamp', descending: true)
//           .limit(1);

//       return activitiesQuery.snapshots().map((snapshot) {
//         if (snapshot.docs.isEmpty) {
//           return EmployeeStatus(status: 'its offline');
//         }

//         final doc = snapshot.docs.first;
//         return EmployeeStatus.fromFirestore(doc);
//       });
//     });

final employeeCurrentStatus = StreamProvider.family
    .autoDispose<
      List<EmployeeStatus>,
      (String companyEmail, String employeeEmail)
    >((ref, params) {
      final (companyEmail, employeeEmail) = params;
      final firestore = FirebaseFirestore.instance;
      final employeesCollection = firestore
          .collection('companies')
          .doc(companyEmail)
          .collection('employees')
          .doc(employeeEmail)
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .limit(1);

      return employeesCollection.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => EmployeeStatus.fromFirestore(doc))
            .toList();
      });
    });
