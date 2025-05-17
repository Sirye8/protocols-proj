import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'database_service.dart';

class AttendanceRecordPage extends StatefulWidget {
  const AttendanceRecordPage({super.key});

  @override
  State<AttendanceRecordPage> createState() => AttendanceRecordPageState();
}

class AttendanceRecordPageState extends State<AttendanceRecordPage> {
  String selectedOption = 'Network Protocols';
  final List<String> dropdownItems = ['Network Protocols', 'Networks Lab', 'Internet'];
  final DatabaseReference dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://protocolsproj-default-rtdb.europe-west1.firebasedatabase.app/',
  ).ref();

  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    setState(() {
      isLoading = true;
      sessions.clear();
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await dbRef
        .child('Attendance_Record/$selectedOption/$uid/sessions')
        .get();

    if (snapshot.exists) {
      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      sessions = raw.entries.map((e) {
        return {
          'session': e.key,
          ...Map<String, dynamic>.from(e.value),
        };
      }).toList();
    }

    setState(() {
      isLoading = false;
    });
  }

  String formatTimestamp(int millis) {
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Attendance Record', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Course',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedOption,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  dropdownColor: Colors.yellow,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  items: dropdownItems.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    setState(() => selectedOption = value!);
                    await fetchAttendanceData();
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
                  : sessions.isEmpty
                  ? const Center(
                child: Text("No sessions found.",
                    style: TextStyle(color: Colors.white70)),
              )
                  : ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Session: ${session['session']}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 6),
                          Text("Attendance: ${session['state']}",
                              style: TextStyle(
                                color: session['state'] == 'attended'
                                    ? Colors.green
                                    : Colors.redAccent,
                              )),
                          const SizedBox(height: 4),
                          Text("Start: ${formatTimestamp(session['start'])}",
                              style: const TextStyle(color: Colors.white70)),
                          Text("End: ${formatTimestamp(session['end'])}",
                              style: const TextStyle(color: Colors.white70)),

                          if (session['state'] == 'attended') ...[
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final uid = FirebaseAuth.instance.currentUser?.uid;
                                if (uid == null) return;

                                final path =
                                    'Attendance_Record/$selectedOption/$uid/sessions/${session['session']}';
                                final dbService = DatabaseService();

                                await dbService.update(
                                  path: path,
                                  data: {'state': 'absent'},
                                );

                                await fetchAttendanceData();
                              },
                              child: const Text("Mark as Absent"),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
