import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();

  String _translatedText = "";
  String _transliteratedText = "";
  bool _isLoading = false;

  // Languages with their local names
  final Map<String, String> languages = {
    'English': 'en',
    'العربية': 'ar',
    'Français': 'fr',
    'Español': 'es',
    'Deutsch': 'de',
    '中文': 'zh-CN',
    '日本語': 'ja',
    '한국어': 'ko',
    'Русский': 'ru',
    'Italiano': 'it',
    'Português': 'pt',
    'Türkçe': 'tr',
    'हिन्दी': 'hi',
    'বাংলা': 'bn',
    'اردو': 'ur',
    'فارسی': 'fa',
    'Tiếng Việt': 'vi',
    'Bahasa Indonesia': 'id',
    'ไทย': 'th',
    'Kiswahili': 'sw',
    'Ελληνικά': 'el',
    'עברית': 'he',
    'Polski': 'pl',
    'Nederlands': 'nl',
    'Čeština': 'cs',
    'Română': 'ro',
    'Magyar': 'hu',
    'Bahasa Melayu': 'ms',
    'Filipino': 'tl',
    'தமிழ்': 'ta',
    'ગુજરાતી': 'gu',
    'తెలుగు': 'te',
    'मराठी': 'mr',
    'ਪੰਜਾਬੀ': 'pa',
    'اردو (Pakistan)': 'ur-PK',
  };

  String sourceLang = 'en';
  String targetLang = 'ar';

  void _swapLanguages() {
    setState(() {
      final temp = sourceLang;
      sourceLang = targetLang;
      targetLang = temp;
    });
  }

  Future<void> _translate() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    final url =
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(_controller.text.trim())}&langpair=$sourceLang|$targetLang';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String translated = data['responseData']['translatedText'];
        setState(() {
          _translatedText = translated;
          _transliteratedText = _toFranco(translated);
          _isLoading = false;
        });
      } else {
        setState(() {
          _translatedText = "Translation error. Please try again.";
          _transliteratedText = "";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _translatedText = "Failed to connect to the internet.";
        _transliteratedText = "";
        _isLoading = false;
      });
    }
  }

  Future<void> _speak(String text, String lang) async {
    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }

  String _toFranco(String arabic) {
    Map<String, String> map = {
      'ا': 'a',
      'ب': 'b',
      'ت': 't',
      'ث': 'th',
      'ج': 'g',
      'ح': '7',
      'خ': '5',
      'د': 'd',
      'ذ': 'dh',
      'ر': 'r',
      'ز': 'z',
      'س': 's',
      'ش': 'sh',
      'ص': '9',
      'ض': '9\'',
      'ط': '6',
      'ظ': '6\'',
      'ع': '3',
      'غ': 'gh',
      'ف': 'f',
      'ق': 'q',
      'ك': 'k',
      'ل': 'l',
      'م': 'm',
      'ن': 'n',
      'ه': 'h',
      'و': 'w',
      'ي': 'y',
      'ء': '\'',
      'أ': 'a',
      'إ': 'i',
      'ؤ': 'o',
      'ئ': 'e',
      'ى': 'a',
      'ة': 'h',
    };
    String result = '';
    for (var ch in arabic.split('')) {
      result += map[ch] ?? ch;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Colors.deepPurple;

    Widget buildDropdown(
      String label,
      String value,
      Function(String) onChanged,
    ) {
      return DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        items:
            languages.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.value,
                    child: Text(e.key, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
        onChanged: (val) => onChanged(val!),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor, width: 2),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text(
          "AI Translator",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 4,
                      child: buildDropdown(
                        "Source Language",
                        sourceLang,
                        (val) => setState(() => sourceLang = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _swapLanguages,
                      icon: const Icon(Icons.swap_horiz, size: 30),
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 4,
                      child: buildDropdown(
                        "Target Language",
                        targetLang,
                        (val) => setState(() => targetLang = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Enter text here",
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: borderColor,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: borderColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : const Icon(Icons.translate, color: Colors.white),
                    label: Text(
                      _isLoading ? "Translating..." : "Translate",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    onPressed: _isLoading ? null : _translate,
                  ),
                ),
                const SizedBox(height: 20),
                if (_translatedText.isNotEmpty)
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SelectableText(
                            _translatedText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _transliteratedText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.deepPurple,
                                ),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: _translatedText),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Text copied'),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.volume_up,
                                  color: Colors.deepPurple,
                                ),
                                onPressed:
                                    () => _speak(_translatedText, targetLang),
                              ),
                            ],
                          ),
                        ],
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
}
