import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String?> pickAndReadText() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        print("❌ لم يتم اختيار أي صورة");
        return null;
      }

      print("✅ تم اختيار الصورة: ${image.path}");

      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      print("📄 النص المستخرج: ${recognizedText.text}");

      return recognizedText.text.isEmpty ? null : recognizedText.text;
    } catch (e) {
      print("🚨 خطأ في OCR: $e");
      return null;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
