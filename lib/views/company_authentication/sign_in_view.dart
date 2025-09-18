import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackermobile/providers/sign_in_providers.dart';
import 'package:trackermobile/services/auth/sign_in_auth_errors.dart';
import 'package:trackermobile/themes/buttons.dart';
import 'package:trackermobile/themes/textfields.dart';

class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(signInControllerProvider);

    // Listen for state changes
    ref.listen<AsyncValue<User?>>(signInControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            context.go('/home');
          }
        },
        error: (error, _) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Login Failed'),
              content: Text(mapAuthErrorToMessage(error)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
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
                children: [
                  Image.asset("assets/images/scrape.png", height: 100),
                  const SizedBox(height: 50),
                  CustomTextField(
                    controller: _email,
                    labelText: 'Email',
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Enter email";
                      final isValid = RegExp(
                        r'^[^@]+@[^@]+\.[^@]+',
                      ).hasMatch(value);
                      return isValid ? null : "Enter valid email";
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _password,
                    labelText: 'Password',
                    prefixIcon: Icons.password,
                    isPassword: true,
                    validator: (value) =>
                        value?.isEmpty ?? true ? "Enter password" : null,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: InkWell(
                      onTap: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          ref
                              .read(signInControllerProvider.notifier)
                              .login(_email.text.trim(), _password.text.trim());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter valid email and password',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: loginState.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                            )
                          : CustomBtns(text: 'Sign in'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      InkWell(
                        onTap: () => context.go('/signup'),
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
