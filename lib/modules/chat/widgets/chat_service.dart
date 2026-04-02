// lib/modules/chat/chat_service.dart
import 'package:dio/dio.dart';
import 'package:ai_super_app/core/config/ai_keys.dart';

class ChatService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AiKey_chat,
      headers: {
        "Authorization": "Bearer $AiKey_chat",
        "Content-Type": "application/json",
      },
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<String> getAIReply(List<Map<String, dynamic>> messages) async {
    try {
      final chatHistory = [
        {
          "role": "system",
          "content":
              "You are a helpful AI assistant. Reply in the same language as the user (Arabic or English).",
        },
        ...messages.map(
          (m) => {
            "role": m['isUser'] ? "user" : "assistant",
            "content": m['text'],
          },
        ),
      ];

      final response = await dio.post(
        "/chat/completions",
        data: {"model": "gpt-4o-mini", "messages": chatHistory},
      );

      if (response.statusCode == 200) {
        return _sanitizeText(
          response.data["choices"][0]["message"]["content"] ?? "",
        );
      } else {
        return "⚠️ Server error ${response.statusCode}";
      }
    } catch (e) {
      return "⚠️ Network or server error: $e";
    }
  }

  String _sanitizeText(String input) =>
      input.replaceAll(RegExp(r'[\uD800-\uDFFF]'), '');
}
