import 'package:flutter/material.dart';
import '/app/mobile/attendance_record_page.dart';
import '/app/mobile/take_attendance_page.dart';
import '/app/mobile/login_page.dart'; // Make sure this import matches your file path

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'WELCOME BACK!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AttendanceRecordPage()),
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/check_attendance.png',
                            height: 120,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Check Attendance',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TakeAttendancePage()),
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/take_attendance.png',
                            height: 120,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Take Attendance',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Logout", style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}