import 'dart:io';
import 'dart:typed_data';
import 'package:ai_super_app/core/config/ai_keys.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class ImageEnhancerPage extends StatefulWidget {
  const ImageEnhancerPage({super.key});

  @override
  State<ImageEnhancerPage> createState() => _ImageEnhancerPageState();
}

class _ImageEnhancerPageState extends State<ImageEnhancerPage> {
  File? _selectedImage;
  String? _enhancedImageUrl;
  bool _isLoading = false;

  final String _apiKey = AiKey_imageEnhancer;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _enhancedImageUrl = null;
      });
    }
  }

  Future<void> _enhanceImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _enhancedImageUrl = null;
    });

    try {
      final url = Uri.parse(AiBaseUrl_imageEnhancer);
      final request =
          http.MultipartRequest("POST", url)
            ..headers['api-key'] = _apiKey
            ..files.add(
              await http.MultipartFile.fromPath("image", _selectedImage!.path),
            );

      final streamedResponse = await request.send();
      final resBody = await streamedResponse.stream.bytesToString();
      final data = json.decode(resBody);

      setState(() {
        _enhancedImageUrl = data["output_url"];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Enhancement failed: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadImage(dynamic source) async {
    try {
      PermissionStatus status = await Permission.photos.request();
      if (!status.isGranted) status = await Permission.storage.request();

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enable storage permission to save images"),
            backgroundColor: Colors.redAccent,
          ),
        );
        openAppSettings();
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Downloading image...")));

      Uint8List bytes;

      if (source is String && source.startsWith("http")) {
        final response = await http.get(Uri.parse(source));
        if (response.statusCode != 200) throw Exception("Download failed");
        bytes = response.bodyBytes;
      } else if (source is File) {
        bytes = await source.readAsBytes();
      } else {
        throw Exception("Invalid image source");
      }

      await Gal.putImageBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Image saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Failed to save image: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI Image Enhancer",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF00B9C3),
        centerTitle: true,
        elevation: 6,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child:
                      _isLoading
                          ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(
                                color: Color(0xFF00B9C3),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Enhancing image...",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          )
                          : _selectedImage == null
                          ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.image_search,
                                size: 90,
                                color: Color(0xFF00B9C3),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Select an image from gallery to start enhancing",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          )
                          : SingleChildScrollView(
                            child: Column(
                              children: [
                                // Original Image
                                Card(
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadowColor: Colors.black26,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      _selectedImage!,
                                      height: 260,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Enhanced Image
                                if (_enhancedImageUrl != null) ...[
                                  const Text(
                                    "Enhanced Image:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadowColor: Colors.black26,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        _enhancedImageUrl!,
                                        height: 260,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                ElevatedButton.icon(
                                  icon: const Icon(Icons.download),
                                  label: const Text("Download Image"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00B9C3),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 24,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    shadowColor: Colors.black45,
                                  ),
                                  onPressed: () {
                                    if (_enhancedImageUrl != null) {
                                      _downloadImage(_enhancedImageUrl!);
                                    } else if (_selectedImage != null) {
                                      _downloadImage(_selectedImage!);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "No image to download.",
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text("Select Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B9C3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black45,
                      ),
                      onPressed: _pickImage,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text("Enhance Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007C91),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black45,
                      ),
                      onPressed:
                          (_selectedImage == null) ? null : _enhanceImage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
