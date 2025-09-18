import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackermobile/providers/fetch_employee_provider.dart';
import 'package:trackermobile/providers/sign_in_providers.dart';

// Global function to handle complete sign out
Future<void> performGlobalSignOut(WidgetRef ref) async {
  // Clear Riverpod state - handle each provider individually
  ref.read(usernameProvider.notifier).state = null;
  ref.invalidate(employeesProvider);
  ref.invalidate(companyDataProvider);

  // Remove the problematic loop that was causing the type error
  // This section was redundant anyway since you're already invalidating
  // the providers individually above

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
