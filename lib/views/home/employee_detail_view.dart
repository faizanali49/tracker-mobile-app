import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trackermobile/models/employee_detail_model.dart';
import 'package:trackermobile/themes/colors.dart';
import 'package:intl/intl.dart';
import 'package:trackermobile/providers/employee_detail_provider.dart';
import 'package:trackermobile/widgets/dialog_box.dart';

class EmployeeDetailPage extends ConsumerStatefulWidget {
  final String employee;
  final String avatar;
  final String? role;
  const EmployeeDetailPage({
    super.key,
    required this.employee,
    required this.avatar,
    required this.role,
  });

  @override
  ConsumerState<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends ConsumerState<EmployeeDetailPage> {
  late String employeeEmail;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late List<DateTime> _daysInWeek;
  String? avatarUrl;
  // final _companyEmail = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    employeeEmail = widget.employee;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _daysInWeek = _getDaysInWeek(_selectedDay);
    avatarUrl = widget.avatar;

    // Initialize the employeeEmailProvider with the current employee's email
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeEmailProvider.notifier).state = employeeEmail;
    });
  }

  // Helper function to get all days of the week for a given day
  List<DateTime> _getDaysInWeek(DateTime day) {
    final startOfWeek = day.subtract(Duration(days: day.weekday));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    // Watch the activityProvider to get the data for the selected day's week
    final activitiesAsyncValue = ref.watch(activityProvider(_selectedDay));

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text("Employee Details"),
        backgroundColor: primaryColor,
        actions: [],
      ),
      // Wrap SingleChildScrollView with RefreshIndicator
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.blue,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator to work
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : const AssetImage('assets/images/user.png')
                              as ImageProvider<Object>,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employeeEmail,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.role ?? 'N/A',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Horizontal Week Calendar
              TableCalendar(
                firstDay: DateTime(
                  DateTime.now().year,
                  DateTime.now().month - 2,
                  DateTime.now().day,
                ),
                lastDay: DateTime.now(), // today is the last selectable day
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.week,
                availableCalendarFormats: const {CalendarFormat.week: 'Week'},
                onDaySelected: (selectedDay, focusedDay) {
                  // Update selected and focused day to trigger provider refresh
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _daysInWeek = _getDaysInWeek(selectedDay);
                  });
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                enabledDayPredicate: (day) {
                  // Disable future days
                  return !day.isAfter(DateTime.now());
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                ),
              ),

              const SizedBox(height: 20),

              // Use Consumer to rebuild based on provider state
              Container(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      200, // Adjust as needed
                ),
                child: activitiesAsyncValue.when(
                  data: (activities) => buildWeeklyReport(activities),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Weekly Report Section
  Widget buildWeeklyReport(List<Activity> allWeeklyActivities) {
    final sortedDays = List<DateTime>.from(_daysInWeek.reversed)
      ..sort((a, b) => b.compareTo(a)); // Reverse chronological order

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedDays.map((day) {
        // Filter activities for the current day
        final dailyActivities =
            allWeeklyActivities
                .where(
                  (activity) => isSameDay(activity.timestamp.toDate(), day),
                )
                .toList()
              // Sort activities by timestamp newest first
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[500]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(day),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (dailyActivities.isEmpty)
                const Text(
                  "No record for this date.",
                  style: TextStyle(color: Colors.black54),
                )
              else
                buildStepperTimeline(dailyActivities),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Easy Stepper Timeline
  Widget buildStepperTimeline(List<Activity> activities) {
    // Reverse the activities list
    final reversedActivities = List<Activity>.from(activities.reversed);

    final steps = reversedActivities.map((activity) {
      return EasyStep(
        customStep: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Image.asset(
            _getIconForStatus(activity.status),
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
        ),
        customTitle: Column(
          children: [
            Text(
              DateFormat('hh:mm a').format(activity.timestamp.toDate()),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }).toList();

    return SizedBox(
      height: 120,
      child: EasyStepper(
        activeStep: 0, // Start at the most recent (first step after reversing)
        showLoadingAnimation: false,
        activeStepBackgroundColor: Colors.transparent,
        finishedStepBackgroundColor: Colors.transparent,
        lineStyle: const LineStyle(
          lineLength: 50,
          lineThickness: 2,
          defaultLineColor: Colors.grey,
          finishedLineColor: Colors.blue,
        ),
        onStepReached: (index) {
          final activity = reversedActivities[index];
          showDialog(
            context: context,
            builder: (context) => ActivityDetailsDialog(activity: activity),
          );
        },
        steps: steps,
      ),
    );
  }

  String _getIconForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return 'assets/images/twitch.png';
      case 'paused':
        return 'assets/images/pause1.png';
      case 'resumed':
        return 'assets/images/resume.png';
      case 'offline':
        return 'assets/images/leave.png';
      default:
        return 'assets/images/twitch.png'; // A default icon
    }
  }

  // Add this method to refresh data efficiently
  Future<void> _refreshData() async {
    // Invalidate only the specific provider for the current week
    ref.invalidate(activityProvider(_selectedDay));

    // Show a snackbar to confirm refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing activity data...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
