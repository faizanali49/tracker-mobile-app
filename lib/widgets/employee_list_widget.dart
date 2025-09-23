import 'package:flutter/material.dart';
import 'package:trackermobile/models/fetch_employee_model.dart';
import 'package:trackermobile/views/home/employee_detail_view.dart';

Widget employeeListWidget(
  BuildContext context,
  FetchEmployee employee,
  Color borderColor,
  Color dotColor,
  bool hasStatus, {
  String? avatarUrl,
  String? role,
}) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmployeeDetailPage(
            employee: employee.email,
            avatar: employee.avatarUrl,
            role: employee.role,
          ),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha:0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage(
              employee.avatarUrl ??
                  'https://www.gravatar.com/avatar/placeholder?d=mp&s=200',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  employee.role,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (hasStatus)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    ),
  );
}
