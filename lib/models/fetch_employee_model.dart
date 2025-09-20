import 'package:cloud_firestore/cloud_firestore.dart';

class FetchEmployee {
  final String id;
  final String name;
  final String role;
  final String email;
  final String status;
  final String avatarUrl;

  FetchEmployee({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.status = 'offline',
    this.avatarUrl = 'N/A',
  });

  factory FetchEmployee.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return FetchEmployee(
      id: doc.id,
      name: data['name'] as String? ?? 'N/A',
      role: data['role'] as String? ?? 'N/A',
      email: data['email'] as String? ?? 'N/A',
      status: data['status'] as String? ?? 'offline',
      avatarUrl: data['avatarUrl'] as String? ?? 'N/A',
    );
  }
}

// NOTE: This class is no longer needed because the Employee model now contains status.
class EmployeeStatus {
  final String status;
  final DateTime? timestamp;
  final String? user;
  final String? comment;
  final String? description;
  final String? title;
  EmployeeStatus({
    required this.status,
    this.timestamp,
    this.user,
    this.comment,
    this.description,
    this.title,
  });

  factory EmployeeStatus.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return EmployeeStatus(
      status: data['status'] as String? ?? 'offline',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      // user: data['user'] as String?,
      comment: data['comment'] as String?,
      description: data['description'] as String?,
      title: data['title'] as String?,
    );
  }
}
