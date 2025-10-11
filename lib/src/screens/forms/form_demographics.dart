import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FormDemographics extends StatefulWidget {
  const FormDemographics({Key? key}) : super(key: key);

  @override
  State<FormDemographics> createState() => _FormDemographicsState();
}

class _FormDemographicsState extends State<FormDemographics> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> fields = {
    "hospitalReg": TextEditingController(),
    "date": TextEditingController(),
    "timeArrival": TextEditingController(),
    "surname": TextEditingController(),
    "firstName": TextEditingController(),
    "dob": TextEditingController(),
    "age": TextEditingController(),
    "infType": TextEditingController(),
    "gender": TextEditingController(),
    "occupation": TextEditingController(),
    "residence": TextEditingController(),
    "arrivalMode": TextEditingController(),
    "numPriorFacilities": TextEditingController(),
    "referredFrom": TextEditingController(),
    "contactPerson": TextEditingController(),
    "phone": TextEditingController(),
    "relation": TextEditingController(),
    "massCasualty": TextEditingController(),
    "triageCategory": TextEditingController(),
    "doa": TextEditingController(),
    "ambulatory": TextEditingController(),
    "condition": TextEditingController(),
  };

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
    for (var controller in fields.values) {
      controller.dispose();
    }
    _speech.stop();
    super.dispose();
  }

  // 🎤 Start listening
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

  // 🎧 Mic animation
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
                      "Demographics",
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

                _sectionHeader("Hospital Information"),
                _buildVoiceField("Hospital Registration Number", fields["hospitalReg"]!),
                _buildVoiceField("Date (DD/MM/YY)", fields["date"]!),
                _buildVoiceField("Time of Arrival (24h)", fields["timeArrival"]!),

                const SizedBox(height: 12),
                _sectionHeader("Patient Information"),
                _buildVoiceField("Surname", fields["surname"]!),
                _buildVoiceField("First Name", fields["firstName"]!),
                _buildVoiceField("Date of Birth (DD/MM/YY)", fields["dob"]!),
                _buildVoiceField("Age", fields["age"]!),
                _buildVoiceField("INF / CH / AD", fields["infType"]!),
                _buildVoiceField("Gender", fields["gender"]!),

                const SizedBox(height: 12),
                _sectionHeader("Other Details"),
                _buildVoiceField("Occupation", fields["occupation"]!),
                _buildVoiceField("Patient Residence (City/Sub-district)", fields["residence"]!),
                _buildVoiceField("Arrival Mode", fields["arrivalMode"]!),
                _buildVoiceField("Number of Prior Facilities", fields["numPriorFacilities"]!),
                _buildVoiceField("Referred From", fields["referredFrom"]!),

                const SizedBox(height: 12),
                _sectionHeader("Contact Person"),
                _buildVoiceField("Contact Person", fields["contactPerson"]!),
                _buildVoiceField("Phone", fields["phone"]!),
                _buildVoiceField("Relation", fields["relation"]!),

                const SizedBox(height: 12),
                _sectionHeader("Triage & Condition"),
                _buildVoiceField("Mass Casualty", fields["massCasualty"]!),
                _buildVoiceField("Triage Category", fields["triageCategory"]!),
                _buildVoiceField("Dead on Arrival", fields["doa"]!),
                _buildVoiceField("Ambulatory", fields["ambulatory"]!),
                _buildVoiceField("Condition", fields["condition"]!),

                const SizedBox(height: 24),
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
                            content: Text("Demographics saved successfully!"),
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

  // 🎤 Field with voice integration
  Widget _buildVoiceField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: () {
          if (voiceMode && !isListening) {
            _startListening(controller);
          }
        },
        child: AbsorbPointer(
          absorbing: voiceMode,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: voiceMode
                  ? Icon(
                      Icons.mic,
                      color: (isListening && _activeController == controller)
                          ? Colors.redAccent
                          : Colors.grey,
                    )
                  : null,
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
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF016969),
        ),
      ),
    );
  }
}
