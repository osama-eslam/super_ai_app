import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Home/ai_article_controller.dart';

class InputBar extends StatelessWidget {
  final AiArticleController controller;
  final bool isDark;

  const InputBar({super.key, required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.inputController,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: "Type topic...",
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  filled: true,
                  fillColor:
                      isDark ? const Color(0xFF2C2C2E) : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child:
                    controller.isLoading.value
                        ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                        : CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              isDark ? Colors.blueAccent.shade700 : Colors.blue,
                          child: IconButton(
                            icon: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                            ),
                            onPressed: controller.generateArticle,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
