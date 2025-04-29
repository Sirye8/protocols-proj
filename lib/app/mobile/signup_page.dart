import 'package:flutter/material.dart';
import '/app/mobile/auth_services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;

  void createAccount() async {
    try {
      await authService.value.createAccount(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => error = "Error while creating account, try again");
    }
  }

  void signUpWithGoogle() async {
    try {
      await authService.value.signInWithGoogle();
      Navigator.pop(context);
    } catch (e) {
      setState(() => error = "Could not sign in with Google");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: createAccount,
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: Image.asset(
                'assets/google_logo.png',
                height: 24,
                width: 24,
              ),
              label: const Text("Sign up with Google"),
              onPressed: signUpWithGoogle,
            ),
          ],
        ),
      ),
    );
  }
}