import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Home/ai_article_controller.dart';

class MessageList extends StatelessWidget {
  final AiArticleController controller;
  final bool isDark;

  const MessageList({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msgs = controller.messages;
      if (msgs.isEmpty) {
        return Center(
          child: Text(
            "Type a topic and press Send to generate an article ✍️",
            style: TextStyle(color: isDark ? Colors.white60 : Colors.black45),
            textAlign: TextAlign.center,
          ),
        );
      }

      return ListView.separated(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        physics: const BouncingScrollPhysics(),
        itemCount: msgs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final message = msgs[index];
          final isUser = message["isUser"] == true;
          final text = message["text"] ?? "";

          final bubbleColor =
              isUser
                  ? (isDark ? Colors.blueAccent.shade700 : Colors.blue.shade600)
                  : (isDark ? const Color(0xFF2C2C2E) : Colors.white);

          final textColor =
              isUser
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.scrollController.hasClients) {
              controller.scrollController.animateTo(
                controller.scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          return Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (!isUser)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.copy_rounded,
                              size: 20,
                              color: isDark ? Colors.white60 : Colors.black45,
                            ),
                            onPressed: () => controller.copyToClipboard(text),
                            tooltip: 'Copy',
                          ),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'save') {
                                controller.storageService.saveArticle({
                                  "id":
                                      DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                  "title": controller.lastPrompt,
                                  "content": text,
                                  "time": DateTime.now().toIso8601String(),
                                }, controller.articles);

                                Get.snackbar(
                                  "Saved",
                                  "Article saved successfully.",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green.shade400,
                                  colorText: Colors.white,
                                );
                              } else if (v == 'delete') {
                                controller.messages.remove(message);
                              }
                            },
                            itemBuilder:
                                (_) => const [
                                  PopupMenuItem(
                                    value: 'save',
                                    child: Text('Save'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete Bubble'),
                                  ),
                                ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
