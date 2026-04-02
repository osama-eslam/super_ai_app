// lib/modules/chat/chat_input_field.dart
import 'package:ai_super_app/modules/chat/Home/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatInputField extends StatelessWidget {
  const ChatInputField({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.attach_file,
                color: theme.colorScheme.primary.withOpacity(0.8),
              ),
              onPressed: controller.pickFile,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: const InputDecoration(
                    hintText: "Type your message...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder:
                    (child, anim) => ScaleTransition(scale: anim, child: child),
                child:
                    controller.isLoading.value
                        ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2.3),
                        )
                        : Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                            ),
                            onPressed: controller.sendMessage,
                          ),
                        ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
