// lib/modules/chat/chat_view.dart
import 'package:ai_super_app/modules/chat/widgets/chat_drawer.dart';
import 'package:ai_super_app/modules/chat/widgets/chat_input_field.dart';
import 'package:ai_super_app/modules/chat/widgets/chat_messages_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0E0E11) : const Color(0xFFF2F4F7),
      drawer: const ChatDrawer(),
      appBar: AppBar(
        title: const Text("AI Assistant 🤖"),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
      ),
      body: Column(
        children: const [
          Expanded(child: ChatMessagesList()),
          Divider(height: 1, thickness: 0.4),
          ChatInputField(),
        ],
      ),
    );
  }
}
