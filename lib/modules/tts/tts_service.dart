import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  /// تشغيل النص
  Future<void> speak(String text, {String language = "en-US"}) async {
    // ✅ تحويل List<dynamic> إلى List<String>
    List<String> langs = (await _flutterTts.getLanguages).cast<String>();
    print("Available languages: $langs");

    await _flutterTts.setLanguage(language);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
