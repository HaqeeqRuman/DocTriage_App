import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FormHistoryIllness extends StatefulWidget {
  const FormHistoryIllness({Key? key}) : super(key: key);

  @override
  State<FormHistoryIllness> createState() => _FormHistoryIllnessState();
}

class _FormHistoryIllnessState extends State<FormHistoryIllness> {
  final _formKey = GlobalKey<FormState>();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool voiceMode = false;
  bool isListening = false;
  TextEditingController? activeController;

  // --- Controllers ---
  final symptomsController = TextEditingController();
  final timeCourseController = TextEditingController();
  final factorsController = TextEditingController();
  final priorEpisodesController = TextEditingController();
  final priorInterventionsController = TextEditingController();

  @override
  void dispose() {
    symptomsController.dispose();
    timeCourseController.dispose();
    factorsController.dispose();
    priorEpisodesController.dispose();
    priorInterventionsController.dispose();
    super.dispose();
  }

  // --- Voice Input Function ---
  Future<void> _listen(TextEditingController controller) async {
    if (!voiceMode) return; // Only works if Voice Mode is ON
    if (!isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          isListening = true;
          activeController = controller;
        });
        _speech.listen(
          onResult: (val) {
            setState(() {
              controller.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => isListening = false);
      _speech.stop();
    }
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
                // ---- Title ----
                const Text(
                  "History of Present Illness",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),

                // ---- Voice Mode Switch aligned to right but below ----
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                          if (!val) {
                            _speech.stop();
                            setState(() => isListening = false);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- Text Areas ---
                _buildTextArea(
                  label: "Symptoms",
                  controller: symptomsController,
                  hint:
                      "Describe the patient’s main symptoms in detail (e.g., pain, cough, fever, weakness)...",
                ),
                _buildTextArea(
                  label: "Time Course",
                  controller: timeCourseController,
                  hint:
                      "Onset, duration, and progression of symptoms (e.g., started 3 days ago, worsening gradually)...",
                ),
                _buildTextArea(
                  label: "Exacerbating & Alleviating Factors",
                  controller: factorsController,
                  hint:
                      "List anything that worsens or improves the condition (e.g., movement, rest, medications)...",
                ),
                _buildTextArea(
                  label: "Prior Episodes",
                  controller: priorEpisodesController,
                  hint:
                      "Any similar symptoms or episodes in the past (include frequency or previous outcomes)...",
                ),
                _buildTextArea(
                  label: "Prior Interventions",
                  controller: priorInterventionsController,
                  hint:
                      "Any interventions already done (e.g., painkillers, antibiotics, physical therapy)...",
                ),

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
                            content: Text(
                              "History of Present Illness saved successfully!",
                            ),
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

  Widget _buildTextArea({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    const primaryColor = Color(0xFF016969);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (voiceMode)
                IconButton(
                  icon: Icon(
                    isListening && activeController == controller
                        ? Icons.mic
                        : Icons.mic_none,
                    color: isListening && activeController == controller
                        ? primaryColor
                        : Colors.grey,
                  ),
                  onPressed: () => _listen(controller),
                ),
            ],
          ),
          TextFormField(
            controller: controller,
            maxLines: 4,
            validator: (val) =>
                val == null || val.isEmpty ? 'This field is required' : null,
            decoration: InputDecoration(
              hintText: hint,
              alignLabelWithHint: true,
              hintStyle:
                  const TextStyle(fontSize: 13, color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
