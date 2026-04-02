// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:ai_super_app/core/config/ai_keys.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageGeneratorPage extends StatefulWidget {
  const ImageGeneratorPage({super.key});

  @override
  State<ImageGeneratorPage> createState() => _ImageGeneratorPageState();
}

class _ImageGeneratorPageState extends State<ImageGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? imageUrl;
  String _selectedSize = "512x512";
  final List<String> generatedImages = [];

  final List<String> fallbackImages = [
    "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800",
    "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
    "https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800",
  ];

  Future<void> generateImage(String prompt) async {
    if (prompt.isEmpty) {
      _showSnack("Please describe the image first.", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      const apiUrl = AiKey_imageGenerator;
      const apiKey = AiBaseUrl_imageGenerator;
      ;

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-image-1",
          "prompt": prompt,
          "size": _selectedSize,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data["data"][0]["url"];
        setState(() {
          imageUrl = url;
          generatedImages.insert(0, url);
        });
      } else {
        _useRandomFallback();
      }
    } catch (_) {
      _useRandomFallback();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _useRandomFallback() {
    final randomImage = fallbackImages[Random().nextInt(fallbackImages.length)];
    setState(() {
      imageUrl = randomImage;
      generatedImages.insert(0, randomImage);
    });
  }

  Future<void> downloadImage(String url) async {
    try {
      PermissionStatus status = await Permission.photos.request();
      if (!status.isGranted) status = await Permission.storage.request();

      if (!status.isGranted) {
        _showSnack(
          "Please enable storage permission to save images.",
          isError: true,
        );
        openAppSettings();
        return;
      }

      _showSnack("Downloading image...");

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception("Download failed");

      final Uint8List bytes = response.bodyBytes;
      await Gal.putImageBytes(bytes);

      _showSnack("✅ Image saved successfully!");
    } catch (e) {
      _showSnack("⚠️ Failed to save image: $e", isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isError ? Colors.redAccent : Colors.orange,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI Image Generator 🎨",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 2,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFFF3E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (imageUrl == null) ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.image_outlined,
                          size: 100,
                          color: Colors.white,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Let's create something amazing ✨",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Describe your idea and AI will bring it to life!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _buildInputField(),
              const SizedBox(height: 20),
              _buildSizeSelector(),
              const SizedBox(height: 20),
              _buildGenerateButton(),
              const SizedBox(height: 30),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child:
                    imageUrl == null
                        ? const SizedBox.shrink()
                        : _buildGeneratedImage(),
              ),
              const SizedBox(height: 30),
              if (generatedImages.isNotEmpty) _buildPreviousImages(),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ تم التعديل هنا
  Widget _buildInputField() {
    return TextField(
      controller: _controller,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintText: "Describe your image idea",
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: const Icon(Icons.edit_outlined, color: Colors.orange),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      maxLines: 2,
    );
  }

  Widget _buildSizeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Image Size:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _selectedSize,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
          items: const [
            DropdownMenuItem(value: "256x256", child: Text("Small")),
            DropdownMenuItem(value: "512x512", child: Text("Medium")),
            DropdownMenuItem(value: "1024x1024", child: Text("Large")),
          ],
          onChanged: (v) => setState(() => _selectedSize = v!),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return GestureDetector(
      onTap: _isLoading ? null : () => generateImage(_controller.text.trim()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepOrange, Colors.orange],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Text(
                  "Generate Image",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildGeneratedImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
          Positioned(
            right: 12,
            top: 12,
            child: _iconButton(
              Icons.download,
              () => downloadImage(imageUrl!),
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🖼️ Previous Images:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: generatedImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  onTap:
                      () => setState(() => imageUrl = generatedImages[index]),
                  child: Image.network(
                    generatedImages[index],
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onPressed, Color color) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}
