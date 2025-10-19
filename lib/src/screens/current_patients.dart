import 'package:flutter/material.dart';
import 'add_case.dart';
import '/widgets/custom_top_bar_dark.dart'; // ✅ Import the reusable top bar

class CurrentPatients extends StatefulWidget {
  const CurrentPatients({Key? key}) : super(key: key);

  @override
  State<CurrentPatients> createState() => _CurrentPatientsState();
}

class _CurrentPatientsState extends State<CurrentPatients> {
  // 🧍 Dummy current patients data
  final List<Map<String, dynamic>> patients = [
    {
      "name": "Ali Raza",
      "age": 32,
      "gender": "Male",
      "mrn": "#100234",
      "contact": "0301-1234567",
      "visitType": "Emergency",
      "reason": "Chest Pain",
      "allergies": "Penicillin",
      "lastVisit": "2025-10-18",
    },
    {
      "name": "Sara Khan",
      "age": 28,
      "gender": "Female",
      "mrn": "#100235",
      "contact": "0321-7654321",
      "visitType": "OPD",
      "reason": "Fever",
      "allergies": "None",
      "lastVisit": "2025-10-15",
    },
    {
      "name": "Ahmed Ali",
      "age": 45,
      "gender": "Male",
      "mrn": "#100236",
      "contact": "0333-9988776",
      "visitType": "Follow-up",
      "reason": "Hypertension",
      "allergies": "Sulfa Drugs",
      "lastVisit": "2025-10-10",
    },
  ];

  @override
  Widget build(BuildContext context) {
    const accentDark = Color(0xFF016969);
    const bgColor = Color(0xFFF8FFFE);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F3),
      appBar: const CustomTopBarDark(title: "Current Patients"), // ✅ Using reusable dark top bar

      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: accentDark.withOpacity(0.08),
                    blurRadius: 6,
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
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: accentDark,
                        ),
                      ),
                      Text(
                        patient['mrn'],
                        style: const TextStyle(
                          fontSize: 13.5,
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
                      fontSize: 13.5,
                      color: Colors.black87,
                    ),
                  ),

                  const Divider(height: 20, thickness: 0.7),

                  // Contact Info
                  _infoRow("Contact", patient['contact']),
                  const SizedBox(height: 6),

                  // Visit Info
                  _infoRow("Visit Type", patient['visitType']),
                  _infoRow("Reason for Visit", patient['reason']),
                  const SizedBox(height: 6),

                  // Allergies + Last Visit
                  _infoRow("Allergies", patient['allergies']),
                  _infoRow("Last Visit Date", patient['lastVisit']),

                  const SizedBox(height: 12),

                  // ➕ Add Case Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddCase(patient: patient),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add,
                          color: Colors.white, size: 16),
                      label: const Text(
                        "Add Case",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
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

  // 🔹 Reusable info row widget
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.8,
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
