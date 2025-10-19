import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '/widgets/custom_top_bar_dark.dart'; // ✅ Reusable top bar

class SmartDoctorForm extends StatefulWidget {
  final Map<String, dynamic> patient; // receives patient info

  const SmartDoctorForm({Key? key, required this.patient}) : super(key: key);

  @override
  State<SmartDoctorForm> createState() => _SmartDoctorFormState();
}

class _SmartDoctorFormState extends State<SmartDoctorForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController primaryConsultantController = TextEditingController();
  final TextEditingController secondaryConsultantController = TextEditingController();
  final TextEditingController presentingComplaintsController = TextEditingController();
  final TextEditingController historyOfIllnessController = TextEditingController();
  final TextEditingController pastMedicalController = TextEditingController();
  final TextEditingController medicationController = TextEditingController();
  final TextEditingController surgeryController = TextEditingController();
  final TextEditingController immunizationController = TextEditingController();
  final TextEditingController personalController = TextEditingController();
  final TextEditingController familyController = TextEditingController();
  final TextEditingController socialController = TextEditingController();
  final TextEditingController bpController = TextEditingController();
  final TextEditingController pulseController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Disease data
  Map<String, List<String>> diseaseSymptoms = {};
  List<String> selectedSymptoms = [];
  bool showAutoFillButton = true;

  @override
  void initState() {
    super.initState();
    _loadDiseaseData();

    // Prefill patient info
    nameController.text = widget.patient['name'] ?? '';
    ageController.text = widget.patient['age']?.toString() ?? '';
    occupationController.text = widget.patient['occupation'] ?? '';
    addressController.text = widget.patient['address'] ?? '';

    presentingComplaintsController.addListener(() {
      final hasText = presentingComplaintsController.text.trim().isNotEmpty;
      if (showAutoFillButton == hasText) {
        setState(() => showAutoFillButton = !hasText);
      }
    });
  }

  Future<void> _loadDiseaseData() async {
    try {
      final csvString = await rootBundle.loadString('assets/data/disease_symptoms.csv');
      final lines = const LineSplitter().convert(csvString);

      for (var line in lines.skip(1)) {
        final parts = line.split(RegExp(r',(?=(?:[^"]*"[^"]*")*[^"]*$)'));
        if (parts.length >= 2) {
          final disease = parts[0].replaceAll('"', '').trim();
          final symptomString = parts[1].replaceAll('"', '').trim();
          if (disease.isNotEmpty && symptomString.isNotEmpty) {
            final symptoms = symptomString
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            diseaseSymptoms[disease] = symptoms;
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading disease data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF016969);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      // ✅ Consistent dark top bar
      appBar: const CustomTopBarDark(title: "Add New Case"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Patient Demographics"),
              _readOnlyField("Full Name", nameController),
              _readOnlyField("Age", ageController),
              _readOnlyField("Gender", TextEditingController(text: widget.patient['gender'] ?? '-')),
              _readOnlyField("MRN", TextEditingController(text: widget.patient['mrn'] ?? '-')),
              _readOnlyField("Contact", TextEditingController(text: widget.patient['contact'] ?? '-')),
              _textField("Occupation", occupationController),
              _textField("Address", addressController),

              _sectionTitle("Admission Details"),
              _textField("Date of Admission", dateController),
              _textField("Time of Admission", timeController),
              _textField("Primary Consultant", primaryConsultantController),
              _textField("Secondary Consultant", secondaryConsultantController),

              _sectionTitle("Clinical History"),
              _multiLineField("Presenting Complaints", presentingComplaintsController),

              if (showAutoFillButton)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showDiseasePicker,
                    icon: const Icon(Icons.local_hospital, color: Colors.white),
                    label: const Text(
                      "Auto-Fill Seasonal Disease",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              const SizedBox(height: 10),

              if (selectedSymptoms.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: -4,
                  children: selectedSymptoms.map((symptom) {
                    return Chip(
                      label: Text(symptom),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          selectedSymptoms.remove(symptom);
                          presentingComplaintsController.text =
                              selectedSymptoms.join(', ');
                        });
                      },
                      backgroundColor: const Color(0xFFE0F7F6),
                      labelStyle: const TextStyle(color: primaryColor),
                    );
                  }).toList(),
                ),

              _multiLineField("History of Present Illness", historyOfIllnessController),
              _multiLineField("Past Medical History", pastMedicalController),
              _multiLineField("History of Medication", medicationController),
              _multiLineField("Past Surgery History", surgeryController),
              _multiLineField("Immunization / Allergies", immunizationController),

              _sectionTitle("Background History"),
              _multiLineField("Personal History", personalController),
              _multiLineField("Family History", familyController),
              _multiLineField("Social History", socialController),

              _sectionTitle("Vital Signs"),
              Row(
                children: [
                  Expanded(child: _textField("Blood Pressure", bpController)),
                  const SizedBox(width: 10),
                  Expanded(child: _textField("Pulse", pulseController)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _textField("Temperature", tempController)),
                  const SizedBox(width: 10),
                  Expanded(child: _textField("Weight", weightController)),
                ],
              ),
              const SizedBox(height: 20),

              _sectionTitle("AI Suggested Follow-up Questions"),
              _aiSuggestionCard([
                "Does the patient have any chronic conditions such as diabetes or hypertension?",
                "Has the patient recently traveled or been exposed to contagious diseases?",
                "Are there any current medications that might interact with treatment?",
                "Was there any sudden change in vital signs prior to admission?",
              ]),
              const SizedBox(height: 30),

              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Case submitted successfully!")),
                      );
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Submit Case",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 📋 Disease Picker
  void _showDiseasePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select a Seasonal Disease",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF016969))),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: diseaseSymptoms.keys.map((disease) {
                    return ListTile(
                      title: Text(disease),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          selectedSymptoms = List<String>.from(diseaseSymptoms[disease] ?? []);
                          presentingComplaintsController.text = selectedSymptoms.join(', ');
                          showAutoFillButton = true;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🧩 Helper UI
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF016969)),
        ),
      );

  Widget _textField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        validator: (val) => val == null || val.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  Widget _multiLineField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _readOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _aiSuggestionCard(List<String> suggestions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7F6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.psychology_alt, color: Color(0xFF016969)),
              SizedBox(width: 8),
              Text(
                "AI Recommendations",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF016969)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bolt, color: Color(0xFF018786), size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(s, style: const TextStyle(color: Colors.black87, height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
