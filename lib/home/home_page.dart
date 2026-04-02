import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ai_super_app/modules/chat/Home/chat_view.dart';
import 'package:ai_super_app/modules/image_generator/image_generator_page.dart';
import 'package:ai_super_app/modules/image_enhancer/image_enhancer_page.dart';
import 'package:ai_super_app/modules/ocr/ocr_page.dart';
import 'package:ai_super_app/modules/stt/stt_page.dart';
import 'package:ai_super_app/modules/translate/translate_page.dart';
import 'package:ai_super_app/modules/tts/tts_page.dart';
import 'package:ai_super_app/modules/ai_article/Home/ai_article_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Bubble> _bubbles = [];
  final rnd = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (int i = 0; i < 50; i++) {
      _bubbles.add(
        _Bubble(
          x: rnd.nextDouble(),
          y: rnd.nextDouble(),
          size: rnd.nextDouble() * 5 + 2,
          speed: rnd.nextDouble() * 0.5 + 0.2,
          color: Colors.white.withOpacity(rnd.nextDouble() * 0.3 + 0.1),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _BubblePainter(_bubbles, _controller.value),
              );
            },
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Choose one of the AI tools 👇",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildGradientCardButton(
                      context,
                      Icons.chat_bubble_outline,
                      "Chat with AI",
                      [Colors.grey.shade800, Colors.grey.shade600],
                      const ChatView(),
                      width,
                    ),
                    const SizedBox(height: 16),
                    _buildGradientCardButton(
                      context,
                      Icons.article_outlined,
                      "Generate AI Articles",
                      [Colors.grey.shade700, Colors.grey.shade500],
                      const AiArticleView(),
                      width,
                    ),
                    const SizedBox(height: 16),
                    _buildGradientCardButton(
                      context,
                      Icons.image,
                      "Generate AI Image",
                      [Colors.orange.shade700, Colors.orange.shade400],
                      const ImageGeneratorPage(),
                      width,
                    ),
                    const SizedBox(height: 16),
                    _buildGradientCardButton(
                      context,
                      Icons.photo_album,
                      "Enhance Images with AI",
                      [const Color(0xFF00B9C3), const Color(0xFF00E0F0)],
                      const ImageEnhancerPage(),
                      width,
                    ),
                    const SizedBox(height: 16),
                    _buildGradientCardButton(
                      context,
                      Icons.camera_alt_outlined,
                      "Convert Image to Text",
                      [Colors.green.shade700, Colors.green.shade400],
                      const OcrPage(),
                      width,
                    ),
                    const SizedBox(height: 16),
                    _buildGradientCardButton(
                      context,
                      Icons.mic,
                      "Speech to Text",
                      [Colors.blue.shade700, Colors.blue.shade400],
                      const SttPage(),
                      width,
                    ),
                    const SizedBox(height: 16),
                    _buildGradientCardButton(
                      context,
                      Icons.record_voice_over,
                      "Text to Speech",
                      [Colors.yellow.shade700, Colors.yellow.shade400],
                      const TtsPage(),
                      width,
                    ),
                    const SizedBox(height: 16),
                    _buildGradientCardButton(
                      context,
                      Icons.translate,
                      "Translate Text",
                      [Colors.purple.shade700, Colors.purple.shade400],
                      const TranslatePage(),
                      width,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientCardButton(
    BuildContext context,
    IconData icon,
    String label,
    List<Color> gradientColors,
    Widget page,
    double width,
  ) {
    return Card(
      elevation: 8,
      shadowColor: Colors.white24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: EdgeInsets.symmetric(vertical: width * 0.05, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: width * 0.09, color: Colors.white),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble {
  double x;
  double y;
  double size;
  double speed;
  Color color;

  _Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double progress;

  _BubblePainter(this.bubbles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var bubble in bubbles) {
      final dy = (bubble.y - progress * bubble.speed) % 1.0;
      final dx = bubble.x * size.width;
      final y = dy * size.height;
      paint.color = bubble.color;
      canvas.drawCircle(Offset(dx, y), bubble.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}
