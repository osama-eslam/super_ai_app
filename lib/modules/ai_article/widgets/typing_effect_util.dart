import 'package:get/get.dart';
import 'dart:async';

Future<void> typeEffect(
  RxList<Map<String, dynamic>> messages,
  int index,
  String text,
  void Function() onUpdate,
) async {
  messages[index]['text'] = "";
  final sanitizedText = String.fromCharCodes(text.runes);

  for (int i = 0; i < sanitizedText.length; i++) {
    await Future.delayed(const Duration(milliseconds: 12));
    messages[index]['text'] = sanitizedText.substring(0, i + 1);
    messages.refresh();
    onUpdate();
  }
}
