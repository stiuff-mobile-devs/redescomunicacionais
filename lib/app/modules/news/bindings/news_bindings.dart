import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/provider/news_provider.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';

class NewsBinding implements Bindings {
  @override
  void dependencies() {
    // Provider (camada de dados/API)
    Get.lazyPut<NewsProvider>(
      () => NewsProvider(),
    );
    
    // Repository (camada de negócio)
    Get.lazyPut<NewsRepository>(
      () => NewsRepository(
        Get.find<NewsProvider>(),
      ),
    );
    
    // Controller (camada de apresentação)
    Get.lazyPut<NewsController>(
      () => NewsController(
        Get.find<NewsRepository>(),
      ),
    );
  }
}
