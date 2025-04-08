// reset_password_page.dart
import 'package:flutter/material.dart';
import '/app/mobile/auth_services.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final emailController = TextEditingController();
  String? message;

  void _sendResetLink() async {
    try {
      await authService.value.resetPassword("", email: emailController.text.trim());
      setState(() => message = "Reset link sent to your email.");
    } catch (e) {
      setState(() => message = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            if (message != null)
              Text(message!, style: const TextStyle(color: Colors.yellow)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, foregroundColor: Colors.black),
              onPressed: _sendResetLink,
              child: const Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}
