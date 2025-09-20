// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Stream<String> getLatestStatusForEmployee(String employeeId, String companyId) {
//     return _firestore
//         .collection('companies')
//         .doc(companyId)
//         .collection('employees')
//         .doc(employeeId)
//         .snapshots()
//         .map((snapshot) {
//       if (snapshot.exists) {
//         return snapshot.data()?['status'] as String? ?? 'offline';
//       }
//       return 'offline';
//     });
//   }
// }
