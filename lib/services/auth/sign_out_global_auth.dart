import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackermobile/providers/sign_in_providers.dart';

// Global function to handle complete sign out
Future<void> performGlobalSignOut(WidgetRef ref) async {
  // Clear Riverpod state - handle each provider individually
  ref.read(companyEmailProvider.notifier).state = null;
  

  try {
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Clear Firestore cache

    await FirebaseFirestore.instance.terminate();
    await FirebaseFirestore.instance.clearPersistence();

    print('Global sign out completed');
  } catch (e) {
    print('Error during global sign out: $e');
  }
}
