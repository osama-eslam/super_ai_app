// lib/modules/chat/chat_messages_list.dart
import 'package:ai_super_app/modules/chat/Home/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class ChatMessagesList extends StatelessWidget {
  const ChatMessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scrollController = ScrollController();

    ever(controller.messages, (_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      });
    });

    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDark
                    ? [const Color(0xFF0F0F12), const Color(0xFF1C1C1E)]
                    : [Colors.white, const Color(0xFFF5F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          key: ValueKey(controller.currentChatId.value),
          controller: scrollController,
          reverse: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            final message =
                controller.messages[controller.messages.length - 1 - index];
            final isUser = message["isUser"] ?? false;
            final bubbleColor =
                isUser
                    ? (isDark
                        ? const Color(0xFF0A84FF)
                        : const Color(0xFF007AFF))
                    : (isDark ? const Color(0xFF2C2C2E) : Colors.white);
            final textColor =
                isUser
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87);

            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        message["text"] ?? "",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15.8,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if ((message["text"] ?? "").length > 70)
                      GestureDetector(
                        onTapDown: (details) async {
                          final overlay =
                              Overlay.of(context).context.findRenderObject()
                                  as RenderBox;
                          final position = RelativeRect.fromRect(
                            Rect.fromPoints(
                              details.globalPosition,
                              details.globalPosition,
                            ),
                            Offset.zero & overlay.size,
                          );

                          await showMenu(
                            context: context,
                            position: position,
                            color:
                                isDark ? const Color(0xFF2C2C2E) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            items: [
                              PopupMenuItem(
                                value: 'copy',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.copy_rounded,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Copy Message",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ).then((value) async {
                            if (value == 'copy') {
                              await Clipboard.setData(
                                ClipboardData(text: message["text"] ?? ""),
                              );
                              Get.snackbar(
                                "Copied",
                                "Message copied successfully ✅",
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(12),
                                borderRadius: 12,
                                backgroundColor:
                                    isDark
                                        ? const Color(0xFF2C2C2E)
                                        : Colors.grey.shade100,
                                colorText:
                                    isDark ? Colors.white : Colors.black87,
                                duration: const Duration(seconds: 2),
                              );
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            size: 18,
                            color: isUser ? Colors.white70 : Colors.black45,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
