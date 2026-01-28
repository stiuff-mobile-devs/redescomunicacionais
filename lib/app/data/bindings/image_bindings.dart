import 'package:get/get.dart';
import 'package:redescomunicacionais/app/services/image_base64_service.dart';

class ImageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageBase64Service>(() => ImageBase64Service());
  }
}
