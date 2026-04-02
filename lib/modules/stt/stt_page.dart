import 'package:flutter/material.dart';
import 'package:ai_super_app/modules/stt/stt_service.dart';

class SttPage extends StatefulWidget {
  const SttPage({super.key});

  @override
  State<SttPage> createState() => _SttPageState();
}

class _SttPageState extends State<SttPage> {
  final SttService _sttService = SttService();
  String _textResult = "";
  bool _isRecording = false;

  void _toggleRecording() async {
    if (!_isRecording) {
      setState(() => _isRecording = true);
      await _sttService.startListening(
        onResult: (text) {
          setState(() => _textResult = text);
        },
        onDone: () {
          setState(() => _isRecording = false);
        },
      );
    } else {
      await _sttService.stopListening();
      setState(() => _isRecording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text display card (مطابق للصفراء)
                  Container(
                    width: screenWidth * 0.9,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.blue.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: SelectableText(
                      _textResult.isEmpty
                          ? "Your recorded text will appear here..."
                          : _textResult,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        height: 1.5,
                        fontFamily: "Roboto",
                      ),
                      minLines: 5, // نفس عدد أسطر المربع الأصفر
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Record button (مطابق للصفراء)
                  ElevatedButton.icon(
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 28,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isRecording ? "Recording..." : "Start Recording",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isRecording
                              ? Colors.redAccent
                              : Colors.blue.shade500,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                      shadowColor: Colors.black26,
                    ),
                    onPressed: _toggleRecording,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "🎤 Speech to Text",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
