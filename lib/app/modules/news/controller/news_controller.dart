import 'dart:convert';
import 'package:flutter/material.dart' show Colors, debugPrint;
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class NewsController extends GetxController {
  final NewsRepository _repository = NewsRepository();
  late final UserController userController;
  late final HomeController homeController;
  late final UserModel user;

  var newss = <NewsModel>[].obs;
  RxBool isLoading = false.obs;
  RxnInt selectedCardIndex = RxnInt();

  @override
  onInit() async {
    super.onInit();
    userController = Get.find<UserController>();
    homeController = Get.find<HomeController>();
    user = await userController.getCurrentUser() ??
        UserModel(id: '', email: '', role: '', createdAt: null, status: '');
    getNewsFromFirebase();
  }

  // Add news - save to both Hive and Firebase
  Future<void> addNews(
    String title,
    String subtitle,
    List<String> cities,
    List<String> categories,
    String body,
    List<String> urlImages,
    String author,
    String email,
    String createdAt,
    String type,
    String status,
    String videoUrl,
  ) async {
    try {
      isLoading(true);
      NewsModel news = NewsModel(
        id: DateTime.now().toIso8601String(),
        title: title,
        subtitle: subtitle,
        cities: cities,
        categories: categories,
        body: body,
        urlImages: urlImages,
        author: author,
        createdBy: email,
        createdAt: DateTime.now(),
        type: type,
        status: status,
        validatedBy: null,
        validatedAt: null,
        editedBy: null,
        editedAt: null,
        excluedBy: null,
        excluedAt: null,
        editedObservation: null,
        validatedObservation: null,
        excludedObservation: null,
        videoUrl: videoUrl,
      );

      try {
        await _repository.saveNewsToHive(news);
      } catch (e) {
        debugPrint("Erro ao salvar notícia no Hive: $e");
      }

      try {
        await _repository.saveNewsToFirebase(news);
      } catch (e) {
        debugPrint("Erro ao salvar notícia no Firebase: $e");
      }

      newss.insert(0, news);
      Get.snackbar(
        'Sucesso',
        'Matéria cadastrada com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível cadastrar a matéria.',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading(false);
    }
  }

  // Get news from Firebase only
  Future<void> getNewsFromFirebase() async {
    try {
      isLoading(true);
      newss.value = await _repository.getNewsFromFirebase();
      newss.sort((a, b) => DateTime.parse(b.createdAt.toString())
          .compareTo(DateTime.parse(a.createdAt.toString())));
    } catch (e) {
      /*Get.snackbar('Erro', 'Não foi possível carregar as notícias.',
          snackPosition: SnackPosition.BOTTOM);*/
    } finally {
      isLoading(false);
    }
  }

  // Get news from Hive only
  Future<void> getNewsFromHive() async {
    try {
      isLoading(true);
      newss.value = await _repository.getNewsFromHive();
      newss.sort((a, b) => DateTime.parse(b.createdAt as String)
          .compareTo(DateTime.parse(a.createdAt as String)));
    } catch (e) {
      debugPrint("Erro ao carregar as notícias do Hive: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<String> hideNews(String newsId, String status, String userEmail,
      String authorEmail, String type) async {
    if (userEmail == authorEmail) {
      String result = "";
      try {
        isLoading(true);

        result = await _repository.hideNews(newsId, status, userEmail);

        if (result == "success") {
          newss.removeWhere(
              (news) => news.id == newsId); // Remove da lista local (interface)
          Get.snackbar(
            'Sucesso',
            '$type excluída com sucesso!',
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.green,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Erro',
          'Não foi possível excluir essa $type.',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
      } finally {
        isLoading(false);
      }
      return result;
    } else {
      Get.snackbar(
        'Erro',
        'Você não tem permissão para excluir esta $type.',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
      return "Você não tem permissão para excluir esta $type.";
    }
  }

  List<dynamic> getValidNews() {
    return newss.where((news) {
      if (news.status != 'publicado') return false;
      try {
        if (news.urlImages[0] != "") {
          base64Decode(news.urlImages[0]);
        }
        return true;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // Prepara o map de argumentos usado nas rotas de detalhe
  Map<String, dynamic> toNewsArguments(NewsModel news) {
    return {
      "titulo": news.title,
      "subtitulo": news.subtitle,
      "cidade": news.cities.isNotEmpty ? news.cities.join(', ') : '',
      "categoria": news.categories.isNotEmpty ? news.categories.join(', ') : '',
      "corpo": news.body,
      "imgurl": news.urlImages.isNotEmpty ? news.urlImages[0] : '',
      "autor": news.author,
      "dataCriacao": news.createdAt.toString(),
      "type": news.type,
      "videoUrl": news.videoUrl,
    };
  }

  // Abre a página de detalhe
  void openNews(NewsModel news) {
    Get.toNamed(Routes.NEWS_PAGE, arguments: toNewsArguments(news));
  }

  // Abre a página de edição (usada quando o usuário pode editar)
  void openEditNews(NewsModel news) {
    Get.toNamed(Routes.EDIT_NEWS, arguments: {
      "newsId": news.id,
      "titulo": news.title,
      "subtitulo": news.subtitle,
      "cidade": news.cities,
      "categoria": news.categories,
      "corpo": news.body,
      "imgurl": news.urlImages.isNotEmpty ? news.urlImages[0] : '',
      "autor": news.author,
      "dataCriacao": news.createdAt.toString(),
      "type": news.type,
      "status": news.status,
    });
  }

  // Verifica se o usuário atual é o autor (p/ habilitar editar/excluir)
  bool canEdit(NewsModel news) {
    return user.email == news.createdBy;
  }

  // Controla seleção de cards (toggle)
  void toggleSelected(int index) {
    if (selectedCardIndex.value == index) {
      selectedCardIndex.value = null;
    } else {
      selectedCardIndex.value = index;
    }
  }

  bool isSelected(int index) => selectedCardIndex.value == index;

  // Mapeamento city -> asset path (adicione as imagens em assets/ e registre no pubspec.yaml)
  final Map<String, String> _cityImageAssets = {
    'São Sebastião do Alto': 'assets/images/cidades/saosebastiaodoalto.jpg',
    'Macuco': 'assets/images/cidades/macuco.jpg',
    'Rio das Flores': 'assets/images/cidades/riodasflores.jpg',
    'Comendador Levy Gasparian': 'assets/images/cidades/levygasparian.jpg',
    'Laje do Muriaé': 'assets/images/cidades/lajedomuriae.jpg',
    'São José de Ubá': 'assets/images/cidades/saojosedeuba.jpg',
    // add more or a 'default' entry
    'default': 'assets/images/default_city.jpg',
  };

  // Retorna o path do asset JPG para a cidade dada
  String getCityImageAsset(String? city) {
    final key = (city == null || city.isEmpty) ? 'default' : city;
    return _cityImageAssets[key] ?? _cityImageAssets['default']!;
  }
}
