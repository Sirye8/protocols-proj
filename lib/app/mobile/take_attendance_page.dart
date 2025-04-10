import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class TakeAttendancePage extends StatefulWidget {
  const TakeAttendancePage({super.key});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  bool isScanning = false;
  bool isConnected = false;
  final String targetMac = "BC:57:29:05:72:73";

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  num calculateDistance(int rssi, int txPower) {
    return pow(10, (txPower - rssi) / (10 * 2));
  }

  void _startScan() async {
    setState(() => isScanning = true);

    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();

    await FlutterBluePlus.startScan();

    FlutterBluePlus.scanResults.listen((results) async {
      for (var result in results) {
        if (result.device.id.id == targetMac) {
          num distance = calculateDistance(result.rssi, -59); // txPower is assumed to be -59
          print("Target device distance: $distance m");

          if (distance <= 10 && !isConnected) {
            await result.device.connect();
            setState(() {
              isConnected = true;
            });
            await FlutterBluePlus.stopScan();
          }
        }
      }
    });
  }

  void _goToHome() {
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
            const Text("Attendance Taken", style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _goToHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
              ),
              child: const Text("Return to Home Page",style: TextStyle(color: Colors.black),
            ),
            )],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/searching.gif', width: 150),
            const SizedBox(height: 16),
            const Text("Taking attendance...", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
