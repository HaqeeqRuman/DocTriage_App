import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FormVitals extends StatefulWidget {
  const FormVitals({Key? key}) : super(key: key);

  @override
  State<FormVitals> createState() => _FormVitalsState();
}

class _FormVitalsState extends State<FormVitals> {
  final _formKey = GlobalKey<FormState>();
  late stt.SpeechToText _speech;

  bool voiceMode = false;
  bool isListening = false;
  String recordedText = "";
  TextEditingController? _activeController;

  // --- Controllers ---
  final timeArrival = TextEditingController();
  final vsTime = TextEditingController();
  final bpSystolic = TextEditingController();
  final bpDiastolic = TextEditingController();
  final pulse = TextEditingController();
  final weight = TextEditingController();
  final heightFeet = TextEditingController();
  final heightInches = TextEditingController();
  final bmi = TextEditingController();
  final rr = TextEditingController();
  final temp = TextEditingController();
  final o2Sat = TextEditingController();
  final o2SatOn = TextEditingController();
  final painScore = TextEditingController();

  // Reassessment
  final reassessTime = TextEditingController();
  final reassessTemp = TextEditingController();
  final reassessPulse = TextEditingController();
  final reassessBpSys = TextEditingController();
  final reassessBpDia = TextEditingController();
  final reassessRR = TextEditingController();
  final reassessSpO2 = TextEditingController();
  final reassessSpO2On = TextEditingController();
  final reassessCondition = TextEditingController();
  final reassessChanges = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    timeArrival.dispose();
    vsTime.dispose();
    bpSystolic.dispose();
    bpDiastolic.dispose();
    pulse.dispose();
    weight.dispose();
    heightFeet.dispose();
    heightInches.dispose();
    bmi.dispose();
    rr.dispose();
    temp.dispose();
    o2Sat.dispose();
    o2SatOn.dispose();
    painScore.dispose();
    reassessTime.dispose();
    reassessTemp.dispose();
    reassessPulse.dispose();
    reassessBpSys.dispose();
    reassessBpDia.dispose();
    reassessRR.dispose();
    reassessSpO2.dispose();
    reassessSpO2On.dispose();
    reassessCondition.dispose();
    reassessChanges.dispose();
    _speech.stop();
    super.dispose();
  }

  // 🎙 Start listening
  Future<void> _startListening(TextEditingController controller) async {
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
    Navigator.of(context).pop();
  }

  // 🎧 Recording dialog
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
                    borderRadius: BorderRadius.circular(12)),
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

  // 🧱 UI
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
                // 🟢 Header with Voice Mode toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Vitals",
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

                // --- VITALS SECTION ---
                _buildVoiceField("Time of Arrival (24h)", timeArrival),
                _buildVoiceField("Initial VS Time (24h)", vsTime),
                Row(
                  children: [
                    Expanded(
                        child: _buildVoiceField(
                            "BP Systolic (mmHg)", bpSystolic)),
                    const SizedBox(width: 10),
                    Expanded(
                        child:
                            _buildVoiceField("Diastolic (mmHg)", bpDiastolic)),
                  ],
                ),
                _buildVoiceField("Pulse (BPM)", pulse),
                _buildVoiceField("Weight (lbs)", weight),
                Row(
                  children: [
                    Expanded(
                        child: _buildVoiceField("Height (Feet)", heightFeet)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _buildVoiceField("Height (Inches)", heightInches)),
                  ],
                ),
                _buildVoiceField("BMI (lb/in²) - Auto Calculated", bmi,
                    enabled: false),
                _buildVoiceField("Respiratory Rate (Per Min)", rr),
                _buildVoiceField("Temperature (°F)", temp),
                _buildVoiceField("O₂ Sat (%)", o2Sat),
                _buildVoiceField("O₂ Sat On (e.g., RA)", o2SatOn),
                _buildVoiceField("Pain Score /10", painScore),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 10),

                const Text(
                  "Reassessment",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                _buildVoiceField("Time (24h)", reassessTime),
                _buildVoiceField("Temp", reassessTemp),
                _buildVoiceField("Pulse", reassessPulse),
                Row(
                  children: [
                    Expanded(
                        child: _buildVoiceField(
                            "BP Systolic", reassessBpSys)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _buildVoiceField(
                            "BP Diastolic", reassessBpDia)),
                  ],
                ),
                _buildVoiceField("RR", reassessRR),
                _buildVoiceField("SpO₂ (%)", reassessSpO2),
                _buildVoiceField("SpO₂ On", reassessSpO2On),
                _buildVoiceField("Condition Same/Changes", reassessCondition),
                _buildVoiceField("Changes", reassessChanges),

                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Vitals saved successfully!")),
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
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              validator: (val) =>
                  val == null || val.isEmpty ? 'This field is required' : null,
              decoration: InputDecoration(
                labelText: label,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
    );
  }
}
