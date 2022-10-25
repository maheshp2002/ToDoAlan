import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart';

SpeechToText  speech = SpeechToText();

class SpeechApi {

  Future<bool> toggleRecording({
    required Function(String text) onResult,
    required ValueChanged<bool> onListening,
  }) async {
    if (speech.isListening) {
      speech.stop();
      return true;
    }

    final isAvailable = await speech.initialize(
      onStatus: (status) {
        onListening(speech.isListening);
      },
      onError: (e) => print('Error: $e'),
    );

    if (isAvailable) {
      speech.listen(onResult: (value) => onResult(value.recognizedWords));
    }

    return isAvailable;
  }
}