import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';

class UpdateNewsController extends GetxController {
  // Repository para acessar os dados
  final NewsRepository newsRepository = NewsRepository();
  final NewsController newsController = Get.find<NewsController>();

  // Estado de carregamento
  final RxBool isLoading = false.obs;

  // Método para atualizar notícia
  Future<String> updateNews(
      String newsId, Map<String, dynamic> updatedData) async {
    try {
      isLoading.value = true;

      // Chama o repository para atualizar
      String result = await newsRepository.updateNews(newsId, updatedData);
      newsRepository
          .syncNewsHiveAndFirebase(); // Sincroniza os dados após atualização
      newsController.getAllNewsFromHive(); // Atualiza as listas no controller
      return result;
    } catch (e) {
      return "Erro ao atualizar notícia: $e";
    } finally {
      isLoading.value = false;
    }
  }

  // Método para validar dados antes de salvar (opcional)
  bool validateNewsData(Map<String, dynamic> data) {
    if (data['title'] == null || data['title'].toString().isEmpty) {
      return false;
    }
    if (data['subtitle'] == null || data['subtitle'].toString().isEmpty) {
      return false;
    }
    if (data['author'] == null || data['author'].toString().isEmpty) {
      return false;
    }
    if (data['body'] == null || data['body'].toString().isEmpty) {
      return false;
    }
    if (data['cities'] == null || (data['cities'] as List).isEmpty) {
      return false;
    }
    if (data['categories'] == null || (data['categories'] as List).isEmpty) {
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    // Cleanup se necessário
    super.onClose();
  }
}
