import 'package:flutter/material.dart';

class FormPastMedical extends StatefulWidget {
  const FormPastMedical({Key? key}) : super(key: key);

  @override
  State<FormPastMedical> createState() => _FormPastMedicalState();
}

class _FormPastMedicalState extends State<FormPastMedical> {
  final _formKey = GlobalKey<FormState>();
  bool voiceMode = false; // 🎙️ Voice mode toggle

  // --- Controllers ---
  final historyObtainedFromController = TextEditingController();
  final medicationsController = TextEditingController();
  final allergiesController = TextEditingController();
  final pastMedicalController = TextEditingController();
  final pastSurgeriesController = TextEditingController();
  final lmpController = TextEditingController();
  final gController = TextEditingController();
  final pController = TextEditingController();
  final contactPersonController = TextEditingController();
  final phoneController = TextEditingController();
  final relationController = TextEditingController();

  String? pregnant;
  String? vaccinationsUpToDate;
  String? tobaccoUse;
  String? alcoholUse;
  String? drugUse;
  String? ivDrugUse;
  String? familyHistory;
  String? safeAtHome;

  @override
  void dispose() {
    historyObtainedFromController.dispose();
    medicationsController.dispose();
    allergiesController.dispose();
    pastMedicalController.dispose();
    pastSurgeriesController.dispose();
    lmpController.dispose();
    gController.dispose();
    pController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
    relationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF016969);
    const bgColor = Color(0xFFF8FFFE);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Container(
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
                // ---- Title + Voice Mode Switch ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Medical History",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          "Voice Mode",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                          activeColor: Colors.teal,
                          inactiveThumbColor: Colors.grey.shade400,
                          value: voiceMode,
                          onChanged: (val) {
                            setState(() => voiceMode = val);
                            debugPrint(val
                                ? "🎙️ Voice mode ON"
                                : "🔇 Voice mode OFF");
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // --- Form Fields ---
                _buildTextField(
                    "History Obtained From", historyObtainedFromController),
                _buildTextArea("Medications", medicationsController),
                _buildTextArea("Allergies", allergiesController),
                _buildTextArea(
                  "Past Medical",
                  pastMedicalController,
                  hint:
                      "HTN, DM, COPD, Psych, Renal Disease, Unknown, Other...",
                ),
                _buildTextArea(
                    "Past Surgeries (type & date)", pastSurgeriesController),

                _buildTextField("Last Menstrual Cycle", lmpController),
                _buildTextField("G", gController),
                _buildTextField("P", pController),

                _buildDropdown("Pregnant?", ["Yes", "No", "Unknown"],
                    (val) => setState(() => pregnant = val)),
                _buildDropdown(
                    "Vaccinations up to date?", ["Yes", "No", "Unknown"],
                    (val) => setState(() => vaccinationsUpToDate = val)),

                const SizedBox(height: 16),
                const Text(
                  "Substance Use",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                _buildDropdown("Tobacco", ["Yes", "No", "Unknown"],
                    (val) => setState(() => tobaccoUse = val)),
                _buildDropdown("Alcohol", ["Yes", "No", "Unknown"],
                    (val) => setState(() => alcoholUse = val)),
                _buildDropdown("Drugs", ["Yes", "No", "Unknown"],
                    (val) => setState(() => drugUse = val)),
                _buildDropdown("IV Drugs", ["Yes", "No", "Unknown"],
                    (val) => setState(() => ivDrugUse = val)),

                const SizedBox(height: 16),
                _buildTextArea("Family History", familyHistory ?? ""),
                _buildDropdown("Safe at home?", ["Yes", "No", "Unknown"],
                    (val) => setState(() => safeAtHome = val)),

                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("Past Medical History saved successfully!"),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Save & Continue",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: (val) =>
            val == null || val.isEmpty ? 'This field is required' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTextArea(String label, dynamic controller, {String? hint}) {
    final isString = controller is String;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: isString ? null : controller,
        initialValue: isString ? controller : null,
        maxLines: 3,
        validator: (val) =>
            val == null || val.isEmpty ? 'This field is required' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: true,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
          hintStyle: const TextStyle(fontSize: 13, color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String label, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        items: options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
        onChanged: onChanged,
        validator: (val) =>
            val == null || val.isEmpty ? 'Please select an option' : null,
      ),
    );
  }
}
