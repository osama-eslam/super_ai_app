import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArticleStorageService {
  final String storageKey;
  final int maxSaved;

  ArticleStorageService({required this.storageKey, this.maxSaved = 3});

  Future<void> saveArticle(
    Map<String, dynamic> article,
    RxList<Map<String, dynamic>> articles,
  ) async {
    articles.insert(0, article);
    while (articles.length > maxSaved) {
      articles.removeLast();
    }
    await _persistArticles(articles);
  }

  Future<void> _persistArticles(RxList<Map<String, dynamic>> articles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(articles.toList()));
  }

  Future<void> loadArticles(RxList<Map<String, dynamic>> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(storageKey);
    if (data != null && data.isNotEmpty) {
      final list = jsonDecode(data);
      articles.value = List<Map<String, dynamic>>.from(list);
    }
  }

  void deleteArticle(String id, RxList<Map<String, dynamic>> articles) {
    articles.removeWhere((a) => a['id'] == id);
    _persistArticles(articles);
  }

  void clearAll(RxList<Map<String, dynamic>> articles) {
    articles.clear();
    _persistArticles(articles);
  }
}
