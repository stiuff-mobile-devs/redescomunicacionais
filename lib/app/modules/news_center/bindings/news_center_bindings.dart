import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news_center/controller/news_center_controller.dart';

class NewsCenterBinding implements Bindings {
@override
void dependencies() {
      Get.lazyPut<NewsCenterController>(() => NewsCenterController());
  
}
}