import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputManager extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _currentText = '';
  TextEditingController? _activeController;

  bool get isListening => _isListening;
  String get currentText => _currentText;

  Future<void> startListening(TextEditingController controller) async {
    _activeController = controller;
    _currentText = '';
    final available = await _speech.initialize();

    if (available) {
      _isListening = true;
      notifyListeners();

      _speech.listen(
        onResult: (result) {
          _currentText = result.recognizedWords;
          if (_activeController != null) {
            _activeController!.text = _currentText;
          }
          notifyListeners();
        },
      );
    }
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  void cancelListening() {
    _speech.cancel();
    _isListening = false;
    _currentText = '';
    notifyListeners();
  }
}
