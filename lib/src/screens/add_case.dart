import 'package:flutter/material.dart';
import 'smart_doctor_form.dart'; // ⬅ New form screen
import '/widgets/custom_top_bar_dark.dart'; // ✅ Reusable dark top bar

class AddCase extends StatefulWidget {
  final Map<String, dynamic> patient;
  const AddCase({Key? key, required this.patient}) : super(key: key);

  @override
  State<AddCase> createState() => _AddCaseState();
}

class _AddCaseState extends State<AddCase> {
  final List<Map<String, String>> previousForms = [
    {"date": "2025-10-15", "diagnosis": "Fever and Cough", "status": "Completed"},
    {"date": "2025-09-20", "diagnosis": "Checkup", "status": "Follow-up due"},
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF016969);
    final patient = widget.patient;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F3),

      // ✅ Reusable top bar with battery area coloring
      appBar: const CustomTopBarDark(title: "Patient Case History"),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧍 Patient Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    "(${patient['age']}y) ${patient['gender']}",
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text("MRN: ${patient['mrn']}",
                      style: const TextStyle(color: Colors.black54)),
                  Text("Contact: ${patient['contact']}",
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🧾 Previous Forms Section
            const Text(
              "Previous Case Forms",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: previousForms.isNotEmpty
                  ? ListView.builder(
                      itemCount: previousForms.length,
                      itemBuilder: (context, index) {
                        final form = previousForms[index];
                        return Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              form['diagnosis'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87),
                            ),
                            subtitle: Text(
                              "Date: ${form['date']} • Status: ${form['status']}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: primaryColor,
                            ),
                            onTap: () {
                              // 📋 Future: open old case form
                            },
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No previous forms found.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
            ),

            const SizedBox(height: 10),

            // ➕ Add New Form Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SmartDoctorForm(patient: patient),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add New Form",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
