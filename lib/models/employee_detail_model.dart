import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String status;
  final String? title;
  final String? comment;
  final Timestamp timestamp;
  final String? spendingTime;
  final String? description;

  Activity({
    required this.status,
    this.title,
    this.comment,
    required this.timestamp,
    this.spendingTime = '',
    this.description,
  });

  // Factory constructor to create an Activity from a Firestore document
  factory Activity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data() ?? {};
    return Activity(
      status: data['status'] ?? 'unknown',
      title: data['title'],
      comment: data['comment'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      spendingTime: data['spended_time'].toString() ,
      description: data['description'], // Map 'description' to 'comment'
    );
  }

  // Method to convert an Activity to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'status': status,
      'title': title,
      'comment': comment,
      'timestamp': timestamp,
      'spendingTime': spendingTime,
      'description': description, // Map 'description' to 'comment'
    };
  }
}
