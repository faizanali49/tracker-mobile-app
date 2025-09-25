import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final emailControllerProvider = StateProvider<String?>((ref) => null);

final forgotpassword = FutureProvider.family<String, String>((
  ref,
  email,
) async {
  // Simulate a network call or any async operation
  await Future.delayed(const Duration(seconds: 2));

  return 'Password reset link sent to $email';
});
