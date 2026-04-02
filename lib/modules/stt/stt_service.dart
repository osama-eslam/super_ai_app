import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SttService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool get isListening => _speech.isListening;

  /// طلب صلاحية الميكروفون
  Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  /// تهيئة STT مع callback لمعرفة الحالة
  Future<bool> initializeSpeech({
    Function? onDone,
    Function(dynamic)? onError,
  }) async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          print("Status: $status");
          if (status == "notListening" && onDone != null) {
            onDone();
          }
        },
        onError: (error) {
          print("Error: $error");
          if (onError != null) onError(error);
        },
      );
    }
    return _isInitialized;
  }

  /// بدء التسجيل واستقبال النتائج مباشرة
  Future<void> startListening({
    String locale = "en_US",
    required Function(String) onResult,
    Function? onDone,
  }) async {
    bool permission = await requestMicrophonePermission();
    if (!permission) return;

    bool ready = await initializeSpeech(
      onDone: onDone,
      onError: (error) {
        // إعادة بدء التسجيل لو كان timeout مؤقت
        if (error.msg == "error_speech_timeout") {
          _speech.listen(
            onResult: (result) => onResult(result.recognizedWords),
            listenFor: const Duration(minutes: 5),
            localeId: locale,
            cancelOnError: true,
            partialResults: true,
          );
        }
      },
    );

    if (!ready) return;

    _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      listenFor: const Duration(minutes: 5),
      localeId: locale,
      cancelOnError: true,
      partialResults: true,
    );
  }

  /// إيقاف التسجيل يدويًا
  Future<void> stopListening() async {
    if (_speech.isListening) await _speech.stop();
  }
}
