import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FormPhysicalExam extends StatefulWidget {
  const FormPhysicalExam({Key? key}) : super(key: key);

  @override
  State<FormPhysicalExam> createState() => _FormPhysicalExamState();
}

class _FormPhysicalExamState extends State<FormPhysicalExam> {
  final _formKey = GlobalKey<FormState>();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _voiceMode = false;
  String _currentFieldKey = '';

  // Controllers for each section
  final Map<String, TextEditingController> _controllers = {
    'general': TextEditingController(),
    'neuroPsych': TextEditingController(),
    'heent': TextEditingController(),
    'neck': TextEditingController(),
    'respiratory': TextEditingController(),
    'cardiac': TextEditingController(),
    'abdominal': TextEditingController(),
    'pelvisGuRectal': TextEditingController(),
    'lymph': TextEditingController(),
    'msk': TextEditingController(),
    'skin': TextEditingController(),
  };

  final Map<String, String?> _normalValues = {
    'general': 'NML',
    'neuroPsych': 'NML',
    'heent': 'NML',
    'neck': 'NML',
    'respiratory': 'NML',
    'cardiac': 'NML',
    'abdominal': 'NML',
    'pelvisGuRectal': 'NML',
    'lymph': 'NML',
    'msk': 'NML',
    'skin': 'NML',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _listen(String fieldKey) async {
    if (!_voiceMode) return;

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
          _currentFieldKey = fieldKey;
        });

        _speech.listen(onResult: (val) {
          setState(() {
            _controllers[fieldKey]!.text = val.recognizedWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
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
                // --- Header with Voice Mode toggle ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Physical Exam",
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
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Switch(
                          activeColor: Colors.teal,
                          value: _voiceMode,
                          onChanged: (val) {
                            setState(() => _voiceMode = val);
                            if (!val) _speech.stop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Repeated Exam Sections ---
                _buildExamSection("General", "general"),
                _buildExamSection("NeuroPsych", "neuroPsych"),
                _buildExamSection("HEENT", "heent"),
                _buildExamSection("Neck", "neck"),
                _buildExamSection("Respiratory", "respiratory"),
                _buildExamSection("Cardiac", "cardiac"),
                _buildExamSection("Abdominal", "abdominal"),
                _buildExamSection("Pelvis / GU / Rectal", "pelvisGuRectal"),
                _buildExamSection("Lymph", "lymph"),
                _buildExamSection("Musculoskeletal", "msk"),
                _buildExamSection("Skin", "skin"),

                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Physical Exam saved!")),
                        );
                      }
                    },
                    child: const Text(
                      "Save & Finish",
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

  Widget _buildExamSection(String title, String key) {
    const primaryColor = Color(0xFF016969);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _normalValues[key],
            decoration: InputDecoration(
              labelText: "Status",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            items: const [
              DropdownMenuItem(value: "NML", child: Text("Normal")),
              DropdownMenuItem(value: "ABN", child: Text("Abnormal")),
              DropdownMenuItem(value: "NT", child: Text("Not Tested")),
            ],
            onChanged: (val) => setState(() => _normalValues[key] = val),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controllers[key],
            maxLines: 2,
            decoration: InputDecoration(
              labelText: "Details if abnormal (Specify L or R if needed)",
              filled: true,
              fillColor: Colors.white,
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixIcon: _voiceMode
                  ? IconButton(
                      icon: Icon(
                        _isListening && _currentFieldKey == key
                            ? Icons.mic
                            : Icons.mic_none,
                        color: _isListening && _currentFieldKey == key
                            ? Colors.red
                            : primaryColor,
                      ),
                      onPressed: () => _listen(key),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
