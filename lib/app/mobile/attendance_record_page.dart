import 'package:flutter/material.dart';

class AttendanceRecordPage extends StatefulWidget {
  const AttendanceRecordPage({super.key});

  @override
  State<AttendanceRecordPage> createState() => AttendanceRecordPageState();
}

class AttendanceRecordPageState extends State<AttendanceRecordPage> {
  String selectedOption = 'Network Protocols';
  final List<String> dropdownItems = ['Network Protocols', 'Networks Lab'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Attendance Record',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Course',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}