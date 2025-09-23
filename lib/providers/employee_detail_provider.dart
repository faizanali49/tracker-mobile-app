import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:trackermobile/models/employee_detail_model.dart';
import 'package:trackermobile/services/employee_detail_service.dart';

// Provider for the ActivityService
final activityService = Provider((ref) => ActivityService());

// Family provider to fetch activities for a specific employee and date
final activityProvider = StreamProvider.family<List<Activity>, DateTime>((
  ref,
  selectedDate,
) {
  final service = ref.watch(activityService);
  final employeeEmail = ref.watch(employeeEmailProvider);

  if (employeeEmail == null) {
    return const Stream.empty();
  }

  return service.streamWeeklyActivities(employeeEmail, selectedDate);
});

// A provider to hold the current employee's email.
final employeeEmailProvider = StateProvider<String?>((ref) => null);

// Provider for activity cache
final activityCacheProvider = StateProvider<Map<String, List<Activity>>>(
  (ref) => {},
);
