// lib/modules/chat/chat_drawer.dart
import 'package:ai_super_app/home/home_page.dart';
import 'package:ai_super_app/modules/chat/Home/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1B1B1E) : Colors.white,
      child: Obx(() {
        return Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "💬 Conversations",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.chats.length,
                itemBuilder: (context, index) {
                  final chat = controller.chats[index];
                  final isCurrent =
                      controller.currentChatId.value == chat['id'];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isCurrent
                              ? theme.colorScheme.primary.withOpacity(0.08)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.chat_bubble_outline,
                        color:
                            isCurrent
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color,
                      ),
                      title: Text(
                        chat['title'] ?? "Untitled",
                        style: TextStyle(
                          color:
                              isCurrent
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (value) {
                          if (value == 'rename') {
                            _renameChatDialog(context, controller, chat['id']);
                          } else if (value == 'delete') {
                            controller.deleteChat(chat['id']);
                          }
                        },
                        itemBuilder:
                            (context) => const [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text('Rename'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        controller.loadChat(chat['id']);
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.add_circle_outline,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                "New Chat",
                style: TextStyle(color: theme.colorScheme.primary),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.startNewChat();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.home_outlined,
                color: Colors.blueAccent,
              ),
              title: const Text(
                "Home",
                style: TextStyle(color: Colors.blueAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Colors.redAccent,
              ),
              title: const Text(
                "Clear All Chats",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text("Clear All Chats?"),
                    content: const Text(
                      "This will delete all your conversations permanently.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: Get.back,
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () {
                          controller.chats.clear();
                          controller.messages.clear();
                          Get.back();
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  void _renameChatDialog(
    BuildContext context,
    ChatController controller,
    String chatId,
  ) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Rename Chat"),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Enter new name"),
            ),
            actions: [
              TextButton(onPressed: Get.back, child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  controller.renameChat(chatId, nameController.text.trim());
                  Get.back();
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }
}
