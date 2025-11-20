import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news_revision/controller/news_revision_controller.dart';

class NewsRevisionBindings implements Bindings {
@override
void dependencies() {
  Get.lazyPut<NewsRevisionController>(() => NewsRevisionController());
  }
}