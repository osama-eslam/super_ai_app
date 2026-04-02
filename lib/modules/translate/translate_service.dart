import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslateService {
  Future<String> translateText(String text, String targetLang) async {
    final url =
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=auto|$targetLang';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['responseData']['translatedText'];
      } else {
        return "حدث خطأ في الترجمة، حاول مرة أخرى";
      }
    } catch (e) {
      return "فشل الاتصال بالإنترنت";
    }
  }
}
