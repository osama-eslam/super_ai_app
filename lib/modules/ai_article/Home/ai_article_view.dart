import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ai_article_controller.dart';
import '../widgets/input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/saved_drawer.dart';

class AiArticleView extends GetView<AiArticleController> {
  const AiArticleView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiArticleController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0E0E11) : const Color(0xFFF5F5F5),
      drawer: SavedDrawer(controller: controller, isDark: isDark),
      appBar: AppBar(
        title: const Text("AI Article Generator"),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        elevation: 1.5,
        shadowColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "New Chat",
            onPressed: controller.newChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: MessageList(controller: controller, isDark: isDark)),
          const Divider(height: 1, thickness: 0.4),
          InputBar(controller: controller, isDark: isDark),
        ],
      ),
    );
  }
}
