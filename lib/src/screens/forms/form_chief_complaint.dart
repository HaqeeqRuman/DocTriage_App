import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FormChiefComplaint extends StatefulWidget {
  const FormChiefComplaint({Key? key}) : super(key: key);

  @override
  State<FormChiefComplaint> createState() => _FormChiefComplaintState();
}

class _FormChiefComplaintState extends State<FormChiefComplaint> {
  final _formKey = GlobalKey<FormState>();
  late stt.SpeechToText _speech;

  final TextEditingController visitType = TextEditingController();
  final TextEditingController reasonForVisit = TextEditingController();
  final TextEditingController source = TextEditingController();
  final TextEditingController chiefComplaint = TextEditingController();

  bool voiceMode = false;
  bool isListening = false;
  TextEditingController? _activeController;
  String recordedText = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    visitType.dispose();
    reasonForVisit.dispose();
    source.dispose();
    chiefComplaint.dispose();
    _speech.stop();
    super.dispose();
  }

  // 🎙 Start listening for speech
  Future<void> _startListening(TextEditingController controller) async {
    if (!voiceMode) return;
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done") setState(() => isListening = false);
      },
      onError: (error) => setState(() => isListening = false),
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

  // 🎧 Recording dialog UI
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

  // 🧱 UI Build
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
                // 🟢 Title + Voice Mode Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Chief Complaint",
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
                            if (!val) {
                              _speech.stop();
                              setState(() => isListening = false);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 Input Fields
                _buildVoiceField("Visit Type", visitType,
                    hint: "e.g., Illness, Injury, Follow-up"),
                _buildVoiceField("Reason for Visit", reasonForVisit,
                    hint: "e.g., Cough, Back Pain"),
                _buildVoiceField("Source of Information", source,
                    hint: "e.g., Self, Family, Referral"),
                _buildVoiceField("Chief Complaint", chiefComplaint,
                    hint: "Describe the main complaint", maxLines: 4),

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
                                Text("Chief Complaint saved successfully!"),
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

  // 🧩 Custom field with mic
  Widget _buildVoiceField(String label, TextEditingController controller,
      {String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
                    (isListening && _activeController == controller)
                        ? Icons.mic
                        : Icons.mic_none,
                    color: (isListening && _activeController == controller)
                        ? Colors.redAccent
                        : Colors.grey,
                  ),
                  onPressed: () => _startListening(controller),
                ),
            ],
          ),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: (val) =>
                val == null || val.isEmpty ? 'This field is required' : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Colors.black38, fontSize: 13),
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
        ],
      ),
    );
  }
}
