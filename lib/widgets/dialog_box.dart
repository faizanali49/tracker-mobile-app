import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:trackermobile/models/employee_detail_model.dart';

class ActivityDetailsDialog extends StatelessWidget {
  final Activity activity;

  const ActivityDetailsDialog({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final String title = activity.title ?? activity.status.toUpperCase();
    final String formattedTime = DateFormat(
      'hh:mm a, MMM dd',
    ).format(activity.timestamp.toDate());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _getIconForStatus(activity.status),
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  activity.comment != null && activity.comment!.isNotEmpty
                      ? activity.comment!
                      : title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            if (activity.description != null &&
                activity.description!.isNotEmpty)
              Text(
                maxLines: 3,
                "description: ${activity.description!}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            if (activity.spendingTime != 'null' &&
                activity.spendingTime!.isNotEmpty)
              Text(
                "Spent Time: ${activity.spendingTime!}",
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            // if (activity.comment != null && activity.comment!.isNotEmpty)
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[100],
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         "Comment:",
            //         style: TextStyle(
            //           fontSize: 14,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.grey[700],
            //         ),
            //       ),
            //       const SizedBox(height: 4),
            //       Text(
            //         activity.comment!,
            //         style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            //       ),
            //       const SizedBox(height: 4),
            //       activity.spendingTime != null &&
            //               activity.spendingTime!.isNotEmpty
            //           ? Text(
            //               "Spent Time: ${activity.spendingTime}",
            //               style: TextStyle(
            //                 fontSize: 14,
            //                 color: Colors.grey[800],
            //               ),
            //             )
            //           : const SizedBox.shrink(),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get icon for status
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
        return 'assets/images/twitch.png';
    }
  }
}
