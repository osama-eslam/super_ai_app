import 'dart:async';
import 'package:ai_super_app/core/config/ai_keys.dart';
import 'package:ai_super_app/modules/ai_article/widgets/ai_service.dart';
import 'package:ai_super_app/modules/ai_article/widgets/article_storage_service.dart';
import 'package:ai_super_app/modules/ai_article/widgets/typing_effect_util.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AiArticleController extends GetxController {
  // Services
  late final AiService aiService;
  late final ArticleStorageService storageService;

  // State
  final messages = <Map<String, dynamic>>[].obs;
  final articles = <Map<String, dynamic>>[].obs;
  final inputController = TextEditingController();
  final isLoading = false.obs;
  final isTyping = false.obs;

  final ScrollController scrollController = ScrollController();
  String lastPrompt = "";

  @override
  void onInit() {
    super.onInit();
    aiService = AiService(AiKey_summarizer);
    storageService = ArticleStorageService(
      storageKey: 'ai_saved_articles',
      maxSaved: 3,
    );

    _loadSavedArticles();
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  bool get useMock {
    if (AiKey_summarizer.trim().isEmpty) return true;
    return false;
  }

  Future<void> generateArticle() async {
    final prompt = inputController.text.trim();
    if (prompt.isEmpty) {
      Get.snackbar('Notice', 'Please enter a topic first.');
      return;
    }

    lastPrompt = prompt;

    messages.add({"text": sanitizeText(prompt), "isUser": true});
    scrollToBottom();
    inputController.clear();

    isLoading.value = true;
    isTyping.value = true;

    String fullReply = "";

    try {
      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 300));
        fullReply = """
The Guardians of Nature: Why Predators Matter

Nature is a finely tuned masterpiece, and wildlife is the heartbeat of this system. While the beauty of lush forests and vast plains captures our eyes, the true strength of the environment lies in its biological balance. At the center of this balance are predators.

1. Ecosystem Engineers
Predators are often called "Keystone Species." This means that without them, the entire ecosystem could collapse. Their primary role is to control the population of herbivores (like deer or rabbits). Without predators:
- Overgrazing occurs, as herbivores multiply and eat all the vegetation.
- Deforestation follows, leading to the loss of habitats for birds and insects.
- Soil Erosion increases because there are no plant roots to hold the earth together.

2. Nature’s Health Inspectors
Predators naturally target the weakest, oldest, or sickest members of a herd. This isn't just about "survival of the fittest"—it is a vital service that:
- Prevents the spread of disease among wildlife.
- Strengthens the gene pool, ensuring only the healthiest animals survive to reproduce.

3. Protecting the Environment from "Pollution"
Predators and scavengers act as nature’s cleanup crew. By consuming carcasses, they prevent the buildup of decaying organic matter that could otherwise:
- Contaminate water sources.
- Breed harmful bacteria and pathogens.
- Pollute the soil.

Summary:
The beauty of nature is more than just a view; it is a functional cycle. Predators are the guardians of this cycle, ensuring that our planet remains green, diverse, and clean.
""";
      } else {
        fullReply = await aiService.generateArticle(prompt);
      }

      // إضافة رسالة الرد
      messages.add({"text": "", "isUser": false});
      await typeEffect(
        messages,
        messages.length - 1,
        fullReply,
        scrollToBottom,
      );

      // حفظ المقال
      await storageService.saveArticle({
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "title": lastPrompt,
        "content": fullReply,
        "time": DateTime.now().toIso8601String(),
      }, articles);
    } catch (e) {
      _setLastMessageText('⚠️ Error: ${e.toString()}');
      Get.snackbar('Error', e.toString());
    } finally {
      isTyping.value = false;
      isLoading.value = false;
      scrollToBottom();
    }
  }

  Future<void> _loadSavedArticles() async {
    await storageService.loadArticles(articles);
  }

  void deleteSavedArticle(String id) {
    storageService.deleteArticle(id, articles);
  }

  void clearSavedWithConfirm() {
    Get.defaultDialog(
      title: "Confirm Deletion",
      middleText: "Do you want to delete all saved articles?",
      textConfirm: "Yes",
      textCancel: "Cancel",
      onConfirm: () {
        storageService.clearAll(articles);
        Get.back();
      },
    );
  }

  Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: sanitizeText(text)));
      Get.snackbar("Copied", "Article copied to clipboard.");
    } catch (e) {
      Get.snackbar("Error", "Could not copy to clipboard.");
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
      );
    });
  }

  String sanitizeText(String text) {
    try {
      return String.fromCharCodes(text.runes);
    } catch (_) {
      return text.replaceAll(RegExp(r'[^\u0000-\uFFFF]'), '');
    }
  }

  void newChat() {
    messages.clear();
    lastPrompt = "";
  }

  void _setLastMessageText(String text) {
    if (messages.isEmpty) return;
    messages.last['text'] = sanitizeText(text);
    messages.refresh();
  }
}
