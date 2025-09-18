import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackermobile/services/auth/auth_service.dart';
import 'package:trackermobile/views/company_authentication/sign_in_view.dart';
import 'package:trackermobile/views/home/home.dart';

// Checks authentication state and directs to appropriate screen
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) return const SignInView();
        // Optionally check emailVerified here:
        // if (!user.emailVerified) return const VerifyEmailScreen();
        return HomeView();
      },
    );
  }
}
