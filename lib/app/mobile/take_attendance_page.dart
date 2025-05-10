import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class TakeAttendancePage extends StatefulWidget {
  const TakeAttendancePage({super.key});

  @override
  State<TakeAttendancePage> createState() => TakeAttendancePageState();
}

class TakeAttendancePageState extends State<TakeAttendancePage> {
  bool isScanning = false;
  bool isConnected = false;
  Map<String, String> macToCourse = {};
  final Map<String, DateTime> detectionStart = {};
  final Duration requiredDuration = const Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    loadBeaconsAndStartScan();
  }

  num calculateDistance(int rssi, int txPower) {
    return pow(10, (txPower - rssi) / (10 * 2));
  }

  Future<void> loadBeaconsAndStartScan() async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('beacons');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((course, mac) {
        macToCourse[mac.toString()] = course.toString();
      });

      await startScan();
    }
  }

  Future<void> startScan() async {
    setState(() => isScanning = true);

    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();

    final dbRef = FirebaseDatabase.instance.ref();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FlutterBluePlus.startScan();

    FlutterBluePlus.scanResults.listen((results) async {
      for (var result in results) {
        final String detectedMac = result.device.id.id;

        if (macToCourse.containsKey(detectedMac)) {
          final num distance = calculateDistance(result.rssi, -59);

          if (distance <= 5) {
            detectionStart.putIfAbsent(detectedMac, () => DateTime.now());
            final timeElapsed = DateTime.now().difference(detectionStart[detectedMac]!);

            if (timeElapsed >= requiredDuration && !isConnected) {
              final String course = macToCourse[detectedMac]!;
              final String uid = user.uid;

              // 1. Check if current time falls within any session of this course
              final sessionsSnap = await dbRef
                  .child('Attendance_Record/$course/$uid/sessions')
                  .get();

              if (sessionsSnap.exists) {
                final now = DateTime.now();
                final sessions = Map<String, dynamic>.from(sessionsSnap.value as Map);

                for (var entry in sessions.entries) {
                  final sessionId = entry.key;
                  final sessionData = Map<String, dynamic>.from(entry.value);
                  final start = DateTime.fromMillisecondsSinceEpoch(sessionData['start']);
                  final end = DateTime.fromMillisecondsSinceEpoch(sessionData['end']);

                  if (now.isAfter(start) && now.isBefore(end)) {
                    // 2. Session is ongoing – mark as present
                    await result.device.connect();
                    await FlutterBluePlus.stopScan();

                    await dbRef
                        .child('Attendance_Record/$course/$uid/sessions/$sessionId/state')
                        .set('attended');

                    setState(() {
                      isConnected = true;
                    });

                    break; // Exit loop after first matching session
                  }
                }
              }
            }
          } else {
            detectionStart.remove(detectedMac); // Out of range
          }
        }
      }
    });
  }

  void returnHome() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Take Attendance"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: isConnected
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/take_attendance.png', width: 150),
            const Text("Attendance Taken",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: returnHome,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
              child: const Text("Return to Home Page",
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/searching.gif', width: 150),
            const SizedBox(height: 16),
            const Text("Taking attendance...",
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
