import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trackermobile/themes/colors.dart';

class EmployeeDetailPage extends ConsumerStatefulWidget {
  final String employee;
  const EmployeeDetailPage({super.key, required this.employee});

  @override
  ConsumerState<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends ConsumerState<EmployeeDetailPage> {
  int activeStep = 0;
  late String employeeEmail;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    employeeEmail = widget.employee;
  }

  @override
  void initState() {
    super.initState();
    employeeEmail = widget.employee;

    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _lastDay = DateTime.now().add(const Duration(days: 30)); // Next 30 days
    _firstDay = DateTime.now().subtract(
      const Duration(days: 30),
    ); // Past 30 days
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text("Employee Details"),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Section
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage("assets/images/employee.jpg"),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      " ${employeeEmail} ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Product Manager",
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
                setState(() {
                  _focusedDay = focusedDay;
                });
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

            const Text(
              "Today:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            buildStepperTimeline(),
          ],
        ),
      ),
    );
  }

  /// Easy Stepper Timeline
  Widget buildStepperTimeline() {
    List<Map<String, dynamic>> steps = [
      {
        "icon": "assets/images/twitch.png",
        "title": "Check In",
        "time": "9:00 AM",
      },
      {
        "icon": "assets/images/pause1.png",
        "title": "Break",
        "time": "12:05 PM",
      },
      {
        "icon": "assets/images/resume.png",
        "title": "Resume",
        "time": "01:00 PM",
      },
      {
        "icon": "assets/images/leave.png",
        "title": "Check Out",
        "time": "05:00 PM",
      },
    ];

    return Container(
      height: 120,
      color: Colors.white,
      child: EasyStepper(
        activeStep: activeStep,
        lineStyle: const LineStyle(
          lineLength: 50,
          lineThickness: 2,
          defaultLineColor: Colors.grey,
          finishedLineColor: Colors.blue,
        ),
        onStepReached: (index) {
          setState(() => activeStep = index);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Clicked ${steps[index]['title']} - ${steps[index]['time']}",
              ),
            ),
          );
        },
        steps: steps.map((step) {
          return EasyStep(
            customStep: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Image.asset(step['icon'], width: 28, height: 28),
            ),
            customTitle: Column(
              children: [
                Text(
                  step['time'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
