import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FormReasonForVisit extends StatefulWidget {
  const FormReasonForVisit({Key? key}) : super(key: key);

  @override
  State<FormReasonForVisit> createState() => _FormReasonForVisitState();
}

class _FormReasonForVisitState extends State<FormReasonForVisit> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController visitTypeController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController sourceInfoController = TextEditingController();

  bool voiceMode = false;
  bool isListening = false;
  String recordedText = "";
  late stt.SpeechToText _speech;
  TextEditingController? _activeController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    visitTypeController.dispose();
    reasonController.dispose();
    sourceInfoController.dispose();
    _speech.stop();
    super.dispose();
  }

  // 🎤 Start speech recognition
  Future<void> _startListening(TextEditingController controller) async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done") {
          setState(() => isListening = false);
        }
      },
      onError: (error) {
        setState(() => isListening = false);
      },
    );

    if (available) {
      setState(() {
        isListening = true;
        _activeController = controller;
        recordedText = "";
      });

      _showRecordingDialog();

      _speech.listen(
        localeId: 'en_US',
        onResult: (result) {
          setState(() {
            recordedText = result.recognizedWords;
            if (_activeController != null) {
              _activeController!.text = recordedText;
            }
          });
        },
      );
    }
  }

  // 🛑 Stop listening
  void _stopListening() async {
    await _speech.stop();
    if (_activeController != null) {
      setState(() {
        _activeController!.text = recordedText;
        isListening = false;
        _activeController = null;
      });
    }
    Navigator.of(context).pop(); // close dialog
  }

  // 🎙 Recording dialog
  void _showRecordingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Recording in progress...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildMicAnimation(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _stopListening,
              icon: const Icon(Icons.stop, color: Colors.white),
              label: const Text(
                "Stop Recording",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎧 Mic pulse animation
  Widget _buildMicAnimation() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: isListening ? 70 : 50,
      height: isListening ? 70 : 50,
      decoration: BoxDecoration(
        color: isListening ? Colors.redAccent : Colors.grey,
        shape: BoxShape.circle,
        boxShadow: [
          if (isListening)
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
        ],
      ),
      child: const Icon(Icons.mic, color: Colors.white, size: 30),
    );
  }

  // 🌦️ Seasonal Diseases Map (basic — you can replace with your CSV later)
  final Map<String, List<String>> seasonalDiseases = {
    "Jan": ["Flu", "Cold", "Asthma", "Bronchitis"],
    "Feb": ["Allergies", "Flu", "Asthma"],
    "Mar": ["Allergies", "Viral Fever", "Asthma"],
    "Apr": ["Chickenpox", "Flu", "Asthma"],
    "May": ["Heatstroke", "Dehydration", "Typhoid"],
    "Jun": ["Malaria", "Dengue", "Diarrhea"],
    "Jul": ["Chikungunya", "Malaria", "Dengue"],
    "Aug": ["Cholera", "Dengue", "Diarrhea"],
    "Sep": ["Typhoid", "Malaria", "Dengue"],
    "Oct": ["Respiratory Infections", "Flu", "Allergies"],
    "Nov": ["Smog-related Illness", "Asthma", "Cough"],
    "Dec": ["Cold", "Pneumonia", "Flu"],
  };

  // 🧾 Show popup with current month's diseases
  void _showSeasonalPopup() {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    List<String> diseases =
        seasonalDiseases[currentMonth] ?? ["No seasonal data available"];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.medical_services, color: Colors.teal),
            const SizedBox(width: 8),
            Text("Diseases in $currentMonth"),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: diseases.length,
            itemBuilder: (context, index) {
              final disease = diseases[index];
              return ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.teal),
                title: Text(disease),
                onTap: () {
                  reasonController.text = disease;
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close", style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF016969);
    const bgColor = Color(0xFFF8FFFE);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🟢 Title + Voice Mode toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Reason for Visit",
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
                          onChanged: (val) => setState(() => voiceMode = val),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Visit Type
                _buildVoiceField(
                  "Visit Type *",
                  "e.g., Illness, Injury, Follow-up",
                  visitTypeController,
                  validatorMsg: "Please enter visit type",
                ),
                const SizedBox(height: 16),

                // Reason for Visit
                _buildVoiceField(
                  "Reason for Visit *",
                  "e.g., Cough, Back Pain",
                  reasonController,
                  validatorMsg: "Please enter reason for visit",
                ),
                const SizedBox(height: 16),

                // Source of Information
                _buildVoiceField(
                  "Source of Information",
                  "e.g., Self, Family, Referral",
                  sourceInfoController,
                ),

                const SizedBox(height: 30),

                // Save button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Reason for Visit saved successfully!"),
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

                const SizedBox(height: 16),

                // 🌿 Auto-fill button
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _showSeasonalPopup,
                    icon: const Icon(Icons.local_hospital_outlined,
                        color: primaryColor),
                    label: const Text(
                      "Auto-fill Seasonal Disease",
                      style: TextStyle(color: primaryColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
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

  // 🎤 Field builder with voice integration
  Widget _buildVoiceField(
    String label,
    String hint,
    TextEditingController controller, {
    String? validatorMsg,
  }) {
    return GestureDetector(
      onTap: () {
        if (voiceMode && !isListening) {
          _startListening(controller);
        }
      },
      child: AbsorbPointer(
        absorbing: voiceMode,
        child: TextFormField(
          controller: controller,
          validator: validatorMsg != null
              ? (val) => val == null || val.isEmpty ? validatorMsg : null
              : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixIcon: voiceMode
                ? Icon(
                    Icons.mic,
                    color: (isListening && _activeController == controller)
                        ? Colors.redAccent
                        : Colors.grey,
                  )
                : null,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
            labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
