import 'package:flutter/material.dart';
import '/app/mobile/auth_services.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final emailController = TextEditingController();
  String? error;

  void sendResetLink() async {
    try {
      await authService.value.resetPassword("", email: emailController.text.trim());
      setState(() => error = "Reset link sent to your email.");
    } catch (e) {
      setState(() => error = "Error while sending reset link");
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
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, foregroundColor: Colors.black),
              onPressed: sendResetLink,
              child: const Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}