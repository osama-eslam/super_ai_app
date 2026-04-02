import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ai_super_app/core/config/moke_mood_list.dart';
import 'package:ai_super_app/modules/chat/widgets/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

const bool useMock = true;

class ChatController extends GetxController {
  final messageController = TextEditingController();
  final messages = <Map<String, dynamic>>[].obs;
  final chats = <Map<String, dynamic>>[].obs;
  final currentChatId = ''.obs;
  final isLoading = false.obs;
  final isTyping = false.obs;
  final selectedFile = Rxn<PlatformFile>();

  final ChatService _service = ChatService();

  @override
  void onInit() {
    super.onInit();
    _loadChats();
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        selectedFile.value = result.files.single;
        final file = File(selectedFile.value!.path!);
        String extractedText = "";

        final ext = selectedFile.value!.extension?.toLowerCase();
        if (ext == "txt") {
          extractedText = await file.readAsString();
        }

        final userMessage =
            extractedText.trim().isNotEmpty
                ? "📄 File content:\n$extractedText"
                : "📎 ${selectedFile.value!.name} (file content not readable)";

        messages.add({"text": userMessage, "isUser": true});
        _updateCurrentChat();

        isTyping.value = true;
        await Future.delayed(const Duration(seconds: 1));

        String reply =
            useMock
                ? "📄 I’ve received the file **${selectedFile.value!.name}**."
                : await _service.getAIReply(messages.toList());

        await _showTypingEffect(reply);
        isTyping.value = false;
        selectedFile.value = null;
        _updateCurrentChat();
      } else {
        Get.snackbar(
          "No File Selected",
          "You didn’t select any file.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick or read file: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('chats');
      if (data != null && data.isNotEmpty) {
        chats.value = List<Map<String, dynamic>>.from(jsonDecode(data));
        if (chats.isNotEmpty) {
          currentChatId.value = chats.first['id'];
          loadChat(currentChatId.value);
        }
      }
    } catch (_) {
      chats.clear();
    }
  }

  Future<void> _saveChats() async {
    unawaited(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('chats', jsonEncode(chats));
      } catch (_) {}
    }());
  }

  void startNewChat() {
    currentChatId.value = DateTime.now().millisecondsSinceEpoch.toString();
    messages.clear();
    chats.insert(0, {
      'id': currentChatId.value,
      'title': 'New Chat',
      'messages': [],
    });
    _saveChats();
  }

  void loadChat(String chatId) {
    final chat = chats.firstWhereOrNull((c) => c['id'] == chatId);
    if (chat != null) {
      currentChatId.value = chatId;
      final List<dynamic> loaded = chat['messages'] ?? [];
      messages.value = loaded.map((m) => Map<String, dynamic>.from(m)).toList();
    } else {
      messages.clear();
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    if (currentChatId.value.isEmpty) startNewChat();

    messages.add({"text": text, "isUser": true});
    messageController.clear();
    isLoading.value = true;
    _updateCurrentChat();

    await Future.delayed(const Duration(milliseconds: 400));
    isTyping.value = true;

    String reply;
    if (useMock) {
      reply = _generateSmartReply(text);
    } else {
      reply = await _service.getAIReply(messages.toList());
    }

    await _showTypingEffect(reply);
    isTyping.value = false;
    _updateCurrentChat();
    isLoading.value = false;
  }

  String _generateSmartReply(String input) {
    final lower = input.toLowerCase();
    for (final key in smartReplies.keys) {
      if (lower.contains(key)) return smartReplies[key]!;
    }

    randomReplies.shuffle();
    return randomReplies.first;
  }

  Future<void> _showTypingEffect(String fullText) async {
    final chars = fullText.runes.toList();
    messages.add({"text": "", "isUser": false});

    for (int i = 0; i < chars.length; i++) {
      await Future.delayed(const Duration(milliseconds: 18));
      messages.last["text"] = String.fromCharCodes(chars.sublist(0, i + 1));
      messages.refresh();
    }
  }

  void _updateCurrentChat() {
    if (currentChatId.value.isEmpty) startNewChat();
    final chatIndex = chats.indexWhere((c) => c['id'] == currentChatId.value);
    if (chatIndex != -1) {
      chats[chatIndex]['messages'] = messages.toList();
      chats[chatIndex]['title'] =
          messages.isNotEmpty
              ? messages.first['text'].split(' ').take(4).join(' ')
              : 'Untitled';
    }
    _saveChats();
  }

  void renameChat(String id, String newName) {
    final index = chats.indexWhere((c) => c['id'] == id);

    if (index != -1) {
      chats[index]['title'] =
          newName.trim().isEmpty ? "Untitled" : newName.trim();
      _saveChats();
      chats.refresh();
    }
  }

  void deleteChat(String id) {
    chats.removeWhere((c) => c['id'] == id);
    _saveChats();
    if (currentChatId.value == id) {
      if (chats.isNotEmpty) {
        loadChat(chats.first['id']);
      } else {
        startNewChat();
      }
    }
  }
}
