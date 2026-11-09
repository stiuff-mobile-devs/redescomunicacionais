import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';

class UpdateNewsController extends GetxController {
  // Repository para acessar os dados
  final NewsRepository newsRepository = NewsRepository();
  late final NewsController newsController;

  // Estado de carregamento
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    newsController = Get.find<NewsController>();
  }

  // Método para atualizar notícia
  Future<String> updateNews(
      String newsId, Map<String, dynamic> updatedData) async {
    try {
      isLoading.value = true;

      // Chama o repository para atualizar
      String result = await newsRepository.updateNews(newsId, updatedData);
      // Atualiza a tela na hora e sincroniza em segundo plano
      await newsController.onLocalNewsChanged();
      return result;
    } catch (e) {
      return "Erro ao atualizar notícia: $e";
    } finally {
      isLoading.value = false;
    }
  }

}
