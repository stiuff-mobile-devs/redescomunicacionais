import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news/controller/create_news_form_controller.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/controller/update_news_ontroller.dart';

class NewsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsController>(() => NewsController());
    Get.lazyPut<CreateNewsFormController>(() => CreateNewsFormController());
    Get.lazyPut<UpdateNewsController>(() => UpdateNewsController());
  }
}
