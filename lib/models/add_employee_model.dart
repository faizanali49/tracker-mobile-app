import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String id;
  final String name;
  final String email;
  final String role;
  final String avatarUrl;
  final String status;
  final bool emailVerified;
  final DateTime? lastActive;
  final DateTime? createdAt;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    required this.status,
    required this.emailVerified,
    this.lastActive,
    this.createdAt,
  });

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Employee(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      status: data['status'] ?? '',
      emailVerified: data['emailVerified'] ?? false,
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
