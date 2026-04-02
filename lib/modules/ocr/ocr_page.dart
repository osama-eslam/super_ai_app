import 'package:ai_super_app/modules/ocr/ocr_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  final OcrService ocr = OcrService();
  String? resultText;
  bool loading = false;
  String? errorMessage;

  @override
  void dispose() {
    ocr.dispose();
    super.dispose();
  }

  void copyToClipboard() {
    if (resultText != null && resultText!.isNotEmpty && mounted) {
      Clipboard.setData(ClipboardData(text: resultText!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> pickAndReadText() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = null;
      resultText = null;
    });

    try {
      final text = await ocr.pickAndReadText();

      if (!mounted) return;
      if (text == null || text.trim().isEmpty) {
        setState(() {
          errorMessage = 'No text detected in the image.';
        });
      } else {
        setState(() {
          resultText = text;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error extracting text: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "🖼️ Image to Text",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // زر اختيار الصورة في منتصف الصفحة
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: Colors.green.shade600,
                    elevation: 8,
                    shadowColor: Colors.black38,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: const Icon(Icons.image, size: 30, color: Colors.white),
                  label: const Text(
                    'Pick Image from Gallery',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: pickAndReadText,
                ),

                const SizedBox(height: 30),

                // Loading indicator
                if (loading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                      strokeWidth: 5,
                    ),
                  ),

                // Error message card
                if (!loading && errorMessage != null)
                  Container(
                    width: screenWidth * 0.9,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.red.shade400,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // Display extracted text with copy icon on top-right
                if (!loading && resultText != null)
                  Container(
                    width: screenWidth * 0.9,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade50, Colors.green.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // النص
                        SingleChildScrollView(
                          child: Text(
                            resultText!,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // أيقونة النسخ في أعلى الكارد على اليمين
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Tooltip(
                            message: 'Copy text',
                            child: Material(
                              color: Colors.green.shade700,
                              shape: const CircleBorder(),
                              elevation: 5,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                ),
                                onPressed: copyToClipboard,
                              ),
                            ),
                          ),
                        ),
                      ],
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
