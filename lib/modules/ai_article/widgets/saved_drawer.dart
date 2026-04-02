import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_super_app/home/home_page.dart';
import '../Home/ai_article_controller.dart';

class SavedDrawer extends StatelessWidget {
  final AiArticleController controller;
  final bool isDark;

  const SavedDrawer({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              "Saved Articles",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const Divider(thickness: 0.6),

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
                Navigator.pop(Get.context!);
                Navigator.pushReplacement(
                  Get.context!,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),

            Expanded(
              child: Obx(() {
                if (controller.articles.isEmpty) {
                  return Center(
                    child: Text(
                      "No saved articles yet.",
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: controller.articles.length,
                  separatorBuilder: (_, __) => const Divider(height: 0.6),
                  itemBuilder: (context, index) {
                    final a = controller.articles[index];
                    return ListTile(
                      title: Text(
                        a['title'] ?? '',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        a['content']?.substring(
                              0,
                              a['content'].length > 40
                                  ? 40
                                  : a['content'].length,
                            ) ??
                            '',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: isDark ? Colors.red.shade400 : Colors.red,
                        ),
                        onPressed: () => controller.deleteSavedArticle(a['id']),
                      ),
                      onTap: () {
                        controller.inputController.text = a['title'] ?? '';
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded),
              title: const Text("Clear All"),
              onTap: controller.clearSavedWithConfirm,
            ),
          ],
        ),
      ),
    );
  }
}
