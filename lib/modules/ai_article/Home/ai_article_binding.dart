import 'package:get/get.dart';
import 'ai_article_controller.dart';

class AiArticleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AiArticleController());
  }
}
