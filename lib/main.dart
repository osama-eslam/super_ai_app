import 'package:ai_super_app/modules/ai_article/Home/ai_article_controller.dart';
import 'package:ai_super_app/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'modules/chat/Home/chat_binding.dart';

void main() {
  Get.put(AiArticleController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: ChatBinding(),
      home: const HomePage(),
    );
  }
}
