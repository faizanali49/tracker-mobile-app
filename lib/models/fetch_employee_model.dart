import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String id;
  final String name;
  final String avatar;
  final String status;
  final String lastActive;
  final String email;
  final String role;

  Employee({
    required this.id,
    required this.name,
    this.avatar = 'assets/images/employee1.jpg',
    this.status = 'offline',
    required this.lastActive,
    required this.email,
    required this.role,
  });

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Format the timestamp for lastActive
    String formattedLastActive = 'Never';
    if (data['lastActive'] != null) {
      try {
        final timestamp = data['lastActive'] as Timestamp;
        final dateTime = timestamp.toDate();
        final now = DateTime.now();
        final difference = now.difference(dateTime);

        if (difference.inMinutes < 60) {
          formattedLastActive = '${difference.inMinutes} min ago';
        } else if (difference.inHours < 24) {
          formattedLastActive = '${difference.inHours} hours ago';
        } else {
          formattedLastActive = '${difference.inDays} days ago';
        }
      } catch (e) {
        formattedLastActive = 'Unknown';
      }
    }

    return Employee(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      avatar: data['avatarUrl'] ?? 'assets/images/employee1.jpg',
      status: data['status'] ?? 'offline',
      lastActive: formattedLastActive,
      email: data['email'] ?? '',
      role: data['role'] ?? 'Employee',
    );
  }
}