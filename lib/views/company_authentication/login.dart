// lib/views/company_authentication/login_view.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackermobile/views/company_authentication/provider/login_state.dart';
import 'package:trackermobile/themes/buttons.dart';
import 'package:trackermobile/themes/textfields.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    
    // Listen for state changes
    ref.listen<AsyncValue<User?>>(loginControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            context.go('/home'); // ✅ go to home if login successful
          }
        },
        error: (error, stackTrace) {
          // Show error dialog
          String errorMessage = 'An error occurred during login.';
          
          if (error is Exception) {
            String errorString = error.toString();
            
            // Check for specific error codes
            if (errorString.contains('employee-access-denied')) {
              errorMessage = 'Access denied. This account is registered as an employee. Please use the employee portal.';
            } else if (errorString.contains('not-company')) {
              errorMessage = 'This account is not registered as a company.';
            } else if (errorString.contains('user-not-found')) {
              errorMessage = 'No user found with this email.';
            } else if (errorString.contains('wrong-password')) {
              errorMessage = 'Incorrect password.';
            } else if (errorString.contains('invalid-email')) {
              errorMessage = 'Invalid email address.';
            } else {
              errorMessage = errorString.replaceFirst('Exception: ', '');
            }
          }
          
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Login Failed'),
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Dismiss the dialog
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
      );
    });
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Company Logo
                  Image.asset(
                    "assets/images/scrape.png", // Put your logo here
                    height: 100,
                  ),

                  const SizedBox(height: 50),

                  /// Email Field
                  CustomTextField(
                    controller: _email,
                    labelText: 'Email',
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }
                      // Simple email regex
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Password Field
                  CustomTextField(
                    controller: _password,
                    labelText: 'Password',
                    prefixIcon: Icons.password,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  /// Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement forgot password
                        print('Forgot password');
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: InkWell(
                      onTap: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          ref
                              .read(loginControllerProvider.notifier)
                              .login(_email.text.trim(), _password.text.trim());
                        } else {
                          // Show validation error
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter valid email and password'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: loginState.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 8, 34, 229),
                              ),
                            )
                          : CustomBtns(text: 'Sign in'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Sign Up Redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      InkWell(
                        onTap: () {
                          context.go('/signup');
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}