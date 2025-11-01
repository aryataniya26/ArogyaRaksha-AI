import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';

class VoiceCommandService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<bool> initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );
    return available;
  }

  Future<void> startListening(Function onEmergencyDetected) async {
    await _speech.listen(
      onResult: (result) {
        final command = result.recognizedWords.toLowerCase();
        debugPrint('Heard: $command');

        if (command.contains('emergency') ||
            command.contains('help me') ||
            command.contains('help')) {
          onEmergencyDetected();
          _speech.stop();
        }
      },
      localeId: 'en_US', // later can add hi_IN / te_IN for Hindi/Telugu
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
}
