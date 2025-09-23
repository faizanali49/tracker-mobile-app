import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackermobile/models/employee_detail_model.dart';

class ActivityService {
  final _db = FirebaseFirestore.instance;
  final _cache = <String, List<Activity>>{};

  Stream<List<Activity>> streamWeeklyActivities(
    String employeeEmail,
    DateTime selectedDay,
  ) {
    final startOfWeek = selectedDay.subtract(
      Duration(days: selectedDay.weekday - 1),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final companyId = FirebaseAuth.instance.currentUser?.email?.toLowerCase();
    if (companyId == null) return Stream.value([]);

    final activitiesRef = _db
        .collection('companies')
        .doc(companyId)
        .collection('employees')
        .doc(employeeEmail)
        .collection('activities');

    return activitiesRef
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek),
        )
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfWeek))
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          final activities = snapshot.docs
              .map((doc) => Activity.fromFirestore(doc, null))
              .toList();

          // keep cache if you still want it
          _cache["${employeeEmail}_${startOfWeek.toIso8601String()}"] =
              activities;

          return activities;
        });
  }
}
