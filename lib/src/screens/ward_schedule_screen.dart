import 'package:flutter/material.dart';

class WardScheduleScreen extends StatefulWidget {
  const WardScheduleScreen({Key? key}) : super(key: key);

  @override
  State<WardScheduleScreen> createState() => _WardScheduleScreenState();
}

class _WardScheduleScreenState extends State<WardScheduleScreen> {
  bool loading = false;
  String error = '';
  int days = 7;
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    fetchDummySchedules();
  }

  void fetchDummySchedules() async {
    setState(() {
      loading = true;
      error = '';
    });

    await Future.delayed(const Duration(seconds: 1)); // simulate delay

    setState(() {
      schedules = [
        {
          'date': '2025-10-19',
          'ward': 'ICU Ward',
          'doctor': 'Dr. Ali Khan',
          'shift': 'Morning',
        },
        {
          'date': '2025-10-19',
          'ward': 'Pediatrics',
          'doctor': 'Dr. Sara Ahmed',
          'shift': 'Evening',
        },
        {
          'date': '2025-10-20',
          'ward': 'Surgical Ward',
          'doctor': 'Dr. Kamran Malik',
          'shift': 'Night',
        },
      ];
      loading = false;
    });
  }

  void generateDummySchedules() async {
    setState(() {
      loading = true;
      error = '';
    });

    await Future.delayed(const Duration(seconds: 1)); // simulate "generation"

    setState(() {
      schedules.add({
        'date': '2025-10-21',
        'ward': 'General Ward',
        'doctor': 'Dr. Hina Javed',
        'shift': 'Morning',
      });
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF016969);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🩺 TITLE SECTION
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: const [
                  Icon(Icons.calendar_today, color: primaryColor),
                  SizedBox(width: 8),
                  Text(
                    "Ward Scheduling",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // 🧭 CONTROL BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Days to Schedule:',
                      style: TextStyle(fontSize: 16, color: Colors.black87)),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: days.toString()),
                      onChanged: (val) {
                        setState(() {
                          days = int.tryParse(val) ?? 7;
                          if (days < 1) days = 1;
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: loading ? null : generateDummySchedules,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Generate Schedule',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📋 SCROLLABLE TABLE
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : error.isNotEmpty
                          ? Center(
                              child: Text(error,
                                  style:
                                      const TextStyle(color: Colors.redAccent)))
                          : SingleChildScrollView(
                              scrollDirection:
                                  Axis.horizontal, // horizontal scroll
                              child: SingleChildScrollView(
                                scrollDirection:
                                    Axis.vertical, // vertical scroll
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                    primaryColor.withOpacity(0.1),
                                  ),
                                  columnSpacing: 40,
                                  columns: const [
                                    DataColumn(
                                        label: Text('Date',
                                            style: TextStyle(
                                                fontWeight:
                                                    FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Ward',
                                            style: TextStyle(
                                                fontWeight:
                                                    FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Doctor',
                                            style: TextStyle(
                                                fontWeight:
                                                    FontWeight.bold))),
                                    DataColumn(
                                        label: Text('Shift',
                                            style: TextStyle(
                                                fontWeight:
                                                    FontWeight.bold))),
                                  ],
                                  rows: schedules.isNotEmpty
                                      ? schedules.map((s) {
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(s['date'] ?? '-')),
                                              DataCell(Text(s['ward'] ?? '-')),
                                              DataCell(
                                                  Text(s['doctor'] ?? '-')),
                                              DataCell(Text(s['shift'] ?? '-')),
                                            ],
                                          );
                                        }).toList()
                                      : const [
                                          DataRow(
                                            cells: [
                                              DataCell(Text('-')),
                                              DataCell(Text(
                                                  'No schedules available')),
                                              DataCell(Text('-')),
                                              DataCell(Text('-')),
                                            ],
                                          ),
                                        ],
                                ),
                              ),
                            ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
