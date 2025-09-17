import 'package:flutter/material.dart';

Widget statusBadge(String status) {
  Color color;
  String text;

  switch (status) {
    case "online":
      color = Colors.green;
      text = "Online";
      break;
    case "offline":
      color = Colors.red;
      text = "Offline";
      break;
    case "paused":
      color = Colors.orange;
      text = "Paused";
      break;
    default:
      color = Colors.grey;
      text = "Unknown";
  }

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: color),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
