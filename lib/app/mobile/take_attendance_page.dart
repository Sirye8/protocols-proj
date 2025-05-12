import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_service.dart';

class TakeAttendancePage extends StatefulWidget {
  const TakeAttendancePage({super.key});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  bool _isScanning = false;
  bool _isConnected = false;
  String _statusMessage = "Initializing...";
  final Map<String, String> _macToCourse = {};
  final Map<String, DateTime> _detectionStartTimes = {};
  final Duration _requiredDuration = const Duration(seconds: 30);
  final double _requiredDistance = 5.0;
  final int _txPower = -59;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAndStartScan();
    _listenToBluetoothState();
  }

  @override
  void dispose() {
    _stopScan();
    _adapterStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeAndStartScan() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Checking permissions...";
    });

    bool permissionsGranted = await _requestPermissions();
    if (!mounted) return;

    if (!permissionsGranted) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Required permissions denied. Cannot scan.";
      });
      return;
    }
    bool beaconsLoaded = await _loadBeacons();

    if (!mounted) return;

    if (!beaconsLoaded) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Could not load beacon data.";
      });
      return;
    }

    await _startScan();
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    bool granted = statuses[Permission.location]?.isGranted ?? false;
    granted &= statuses[Permission.bluetoothScan]?.isGranted ?? false;
    granted &= statuses[Permission.bluetoothConnect]?.isGranted ?? false;

    return granted;
  }

  Future<bool> _loadBeacons() async {
    setState(() {
      _statusMessage = "Loading beacon configuration...";
    });
    final snapshot = await _dbService.read(path: 'beacons');
    if (snapshot != null && snapshot.exists && snapshot.value is Map) {
      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      _macToCourse.clear();
      data.forEach((course, mac) {
        if (course != null && mac != null) {
          _macToCourse[mac.toString().toUpperCase()] = course.toString();
        }
      });
      return _macToCourse.isNotEmpty;
    } else {
      return false;
    }
  }

  void _listenToBluetoothState() {
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state != BluetoothAdapterState.on && _isScanning) {
        if (mounted) {
          setState(() {
            _isScanning = false;
            _isLoading = false;
            _statusMessage = "Bluetooth is turned off.";
          });
          _stopScan();
        }
      } else if (state == BluetoothAdapterState.on && !_isScanning && !_isConnected && !_isLoading) {
        _initializeAndStartScan();
      }
    });
  }

  Future<void> _startScan() async {
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = "Bluetooth is off.";
        });
      }
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = "User not logged in.";
        });
      }
      return;
    }

    setState(() {
      _isLoading = false;
      _isScanning = true;
      _statusMessage = "Searching for classroom beacon...\nStay within $_requiredDistance meters for ${_requiredDuration.inSeconds} seconds.";
    });

    await _scanSubscription?.cancel();
    _scanSubscription = null;

    await FlutterBluePlus.startScan(timeout: null);

    _scanSubscription = FlutterBluePlus.scanResults.listen(
      _onScanResult,
    );
  }

  void _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    if(FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
    }
    if (mounted && _isScanning) {
      setState(() { _isScanning = false; });
    }
  }


  void _onScanResult(List<ScanResult> results) {
    if (!_isScanning || _isConnected) return;

    final now = DateTime.now();
    final user = _auth.currentUser;
    if (user == null) {
      _stopScan();
      if(mounted) setState(() => _statusMessage = "User session ended.");
      return;
    }
    final String uid = user.uid;

    for (var result in results) {
      final String detectedMac = result.device.remoteId.toString().toUpperCase();

      if (_macToCourse.containsKey(detectedMac)) {
        final num distance = _calculateDistance(result.rssi, _txPower);

        if (distance <= _requiredDistance) {
          _detectionStartTimes.putIfAbsent(detectedMac, () => now);
          final timeElapsed = now.difference(_detectionStartTimes[detectedMac]!);
          if (timeElapsed >= _requiredDuration) {
            _markAttendance(detectedMac, uid);
            return;
          }
        } else {
          if (_detectionStartTimes.containsKey(detectedMac)) {
            _detectionStartTimes.remove(detectedMac);
          }
        }
      }
    }
  }

  Future<void> _markAttendance(String detectedMac, String uid) async {
    if (_isConnected) return;

    _stopScan();

    setState(() {
      _statusMessage = "Verifying session and marking attendance...";
    });

    final String course = _macToCourse[detectedMac]!;
    final String sessionsPath = 'Attendance_Record/$course/$uid/sessions';
    bool attendanceMarked = false;
    final sessionsSnap = await _dbService.read(path: sessionsPath);

    if (sessionsSnap != null && sessionsSnap.exists && sessionsSnap.value is Map) {
      final sessions = Map<String, dynamic>.from(sessionsSnap.value as Map);
      final now = DateTime.now();

      for (var entry in sessions.entries) {
        final sessionId = entry.key;
        if (entry.value is Map) {
          final sessionData = Map<String, dynamic>.from(entry.value);
          final startMillis = sessionData['start'] as int?;
          final endMillis = sessionData['end'] as int?;
          final currentState = sessionData['state'] as String?;

          if (startMillis != null && endMillis != null) {
            final start = DateTime.fromMillisecondsSinceEpoch(startMillis);
            final end = DateTime.fromMillisecondsSinceEpoch(endMillis);

            if (now.isAfter(start) && now.isBefore(end) && currentState != 'attended') {
              final String sessionUpdatePath = '$sessionsPath/$sessionId';
              await _dbService.update(
                path: sessionUpdatePath,
                data: {'state': 'attended'},
              );
              attendanceMarked = true;
              break;
            }
          }
        }
      }
    } else {
    }

    if (mounted) {
      if (attendanceMarked) {
        setState(() {
          _isConnected = true;
          _statusMessage = "Attendance Taken Successfully!";
        });
      } else {
        setState(() {
          _statusMessage = "Session already attended \n Or no active session.";
        });
      }
    }
  }

  num _calculateDistance(int rssi, int txPower) {
    if (rssi == 0) {
      return -1.0;
    }
    return pow(10, (txPower - rssi) / (10 * 2));
  }

  void _returnHome() {
    _stopScan();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Take Attendance"),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _returnHome,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isConnected) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/take_attendance.png', width: 150),
          const SizedBox(height: 20),
          Text(_statusMessage,
              style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _returnHome,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
            child: const Text("Return to Home Page", style: TextStyle(color: Colors.black)),
          ),
        ],
      );
    } else if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.yellow),
          const SizedBox(height: 20),
          Text(_statusMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        ],
      );
    } else if (_isScanning) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/searching.gif', width: 150),
          const SizedBox(height: 20),
          Text(_statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white)),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 80),
          const SizedBox(height: 20),
          Text(_statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _initializeAndStartScan,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
            child: const Text("Retry Scan", style: TextStyle(color: Colors.black)),
          )
        ],
      );
    }
  }
}