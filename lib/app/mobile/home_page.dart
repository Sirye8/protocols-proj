import 'package:flutter/material.dart';
import '/app/mobile/attendance_record_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
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
                        'assets/check_attendance.jpeg',
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
                    // navigate to take attendance page (you can create this next)
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/take_attendance.jpeg',
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
      ),
    );
  }

}
