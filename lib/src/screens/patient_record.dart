import 'package:flutter/material.dart';
import 'add_triage.dart'; // ✅ Import the triage form screen

class PatientRecord extends StatefulWidget {
  const PatientRecord({Key? key}) : super(key: key);

  @override
  State<PatientRecord> createState() => _PatientRecordState();
}

class _PatientRecordState extends State<PatientRecord> {
  // Dummy data — later replace with backend data model
  final List<Map<String, dynamic>> patients = [
    {
      "name": "Arlene McCoy",
      "age": 25,
      "gender": "Female",
      "mrn": "#8786541",
      "contact": "765-251-7253",
      "visitType": "",
      "reason": "",
      "allergies": "",
      "lastVisit": "",
    },
    // More patients can be added later dynamically
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF016969);
    const bgColor = Color(0xFFF8FFFE);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F3),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🧑‍⚕️ Header Row (Name + MRN)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        patient['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        patient['mrn'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Age & Gender
                  Text(
                    "(${patient['age']}y) ${patient['gender']}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),

                  const Divider(height: 20, thickness: 0.8),

                  // Contact Info
                  _infoRow("Contact", patient['contact']),

                  const SizedBox(height: 8),

                  // Visit Info
                  _infoRow(
                    "Visit Type",
                    patient['visitType'].isEmpty ? "—" : patient['visitType'],
                  ),
                  _infoRow(
                    "Reason for Visit",
                    patient['reason'].isEmpty ? "—" : patient['reason'],
                  ),

                  const SizedBox(height: 8),

                  // Allergies + Last Visit
                  _infoRow(
                    "Allergies",
                    patient['allergies'].isEmpty ? "—" : patient['allergies'],
                  ),
                  _infoRow(
                    "Last Visit Date",
                    patient['lastVisit'].isEmpty ? "—" : patient['lastVisit'],
                  ),

                  const SizedBox(height: 16),

                  // ➕ Add Triage Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        elevation: 3,
                      ),
                      onPressed: () {
                        // ✅ Navigate to triage form screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddTriage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text(
                        "Add Triage",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
