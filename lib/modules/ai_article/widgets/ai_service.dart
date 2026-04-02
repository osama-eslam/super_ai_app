import 'package:dio/dio.dart';
import 'package:ai_super_app/core/config/ai_keys.dart';

class AiService {
  final Dio dio;

  AiService(String apiKey)
    : dio = Dio(
        BaseOptions(
          baseUrl: AiBaseUrl_summarizer,
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
        ),
      );

  Future<String> generateArticle(String prompt) async {
    final resp = await dio.post(
      "/chat/completions",
      data: {
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a professional English article writer. Write clear, structured articles.",
          },
          {"role": "user", "content": "Write an article about: $prompt"},
        ],
        "temperature": 0.6,
        "max_tokens": 1200,
      },
    );

    return resp.data['choices']?[0]?['message']?['content'] ?? 'No content.';
  }
}
