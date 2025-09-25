import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackermobile/providers/forgot_password_provider.dart';
import 'package:trackermobile/themes/buttons.dart';
import 'package:trackermobile/themes/textfields.dart';

class ForgetPassword extends ConsumerWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = TextEditingController();
    String? _email = ref.watch(emailControllerProvider);
    final emailSent = _email == null ? null : ref.watch(forgotpassword(_email));
    return Scaffold(
      appBar: AppBar(title: const Text('Forget Password')),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            CustomTextField(
              controller: emailController,
              labelText: 'Email',
              prefixIcon: Icons.email,
            ),

            const SizedBox(height: 40),

            InkWell(
              onTap: () {
                final email = emailController.text.trim();
                if (email.isNotEmpty && EmailValidator.validate(email)) {
                  ref.read(emailControllerProvider.notifier).state = email;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid email')),
                  );
                }
              },
              child: CustomBtns(text: 'Send link'),
            ),
            SizedBox(height: 20),
            if (emailSent != null)
              emailSent.when(
                data: (data) => Text(data),
                loading: () => CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
          ],
        ),
      ),
    );
  }
}
