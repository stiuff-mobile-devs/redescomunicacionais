import 'dart:convert';
import 'package:flutter/material.dart' show Colors, debugPrint;
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/utils/components/popups.dart';

class NewsController extends GetxController {
  final NewsRepository _repository = NewsRepository();
  late UserController userController;
  late UserModel user;

  HomeController get homeController => Get.find<HomeController>();

  var inAnalysisNewsList = <NewsModel>[].obs;
  var myDraftsList = <NewsModel>[].obs;
  var rejectedNewsList = <NewsModel>[].obs;
  var deletedNewsList = <NewsModel>[].obs;
  var publishedNewsList = <NewsModel>[].obs;

  RxBool isLoading = false.obs;
  RxnInt selectedCardIndex = RxnInt();

  @override
  onInit() async {
    super.onInit();
    userController = Get.find<UserController>();
    user = await userController.getCurrentUser();
    await _repository.syncNewsHiveAndFirebase();
    await getAllNewsFromHive();
  }

  // Abre a página de detalhe
  void openNews(NewsModel news) {
    Get.toNamed(Routes.NEWS_PAGE, arguments: toNewsArguments(news));
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
      "validatedBy": news.validatedBy ?? '',
      "validatedByName": news.validatedByName ?? '',
    };
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

  Future<void> addNews(
    String title,
    String? subtitle,
    List<String> cities,
    List<String> categories,
    String body,
    List<String> urlImages,
    String author,
    String email,
    String type,
    String status,
    String? videoUrl,
  ) async {
    isLoading(true);

    try {
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
        videoUrl: videoUrl,
        lastUpdated: DateTime.now(),
      );

      //  Tentar salvar no Hive
      try {
        await _repository.saveNewsToHive(news);
        _repository
            .syncNewsHiveAndFirebase(); // Sincroniza os dados após atualização
        getAllNewsFromHive(); // Atualiza as listas no controller
      } catch (e) {
        debugPrint("Hive falhou: $e.");
        throw Exception("Erro ao salvar notícia: $e");
      }
    } catch (e) {
      throw Exception("Erro ao salvar notícia: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> getAllNewsFromHive() async {
    try {
      isLoading(true);

      final allNews = await _repository.getNewsFromHive();

      inAnalysisNewsList.assignAll(
        allNews.where((news) => news.status == NewsStates.emAnalise).toList(),
      );
      myDraftsList.assignAll(
        allNews.where((news) => news.status == NewsStates.rascunho).toList(),
      );
      rejectedNewsList.assignAll(
        allNews.where((news) => news.status == NewsStates.rejeitado).toList(),
      );
      deletedNewsList.assignAll(
        allNews.where((news) => news.status == NewsStates.deletado).toList(),
      );
      publishedNewsList.assignAll(
        allNews.where((news) => news.status == NewsStates.publicado).toList(),
      );
    } catch (e) {
      debugPrint("Erro no Controller (Hive): $e");
    } finally {
      isLoading(false);
    }
  }

  bool _hasRenderableImage(NewsModel news) {
    try {
      if (news.urlImages.isNotEmpty && news.urlImages[0] != "") {
        base64Decode(news.urlImages[0]);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // Função para "deletar" a noticia (na verdade, muda o status para "deletado")
  Future<void> hideNews({
    required String newsId,
    required String status,
    required String userEmail,
    required String type,
  }) async {
    isLoading(true);

    try {
      await _repository.hideNews(newsId, status, userEmail);
      _repository
          .syncNewsHiveAndFirebase(); // Sincroniza os dados após atualização
      getAllNewsFromHive(); // Atualiza as listas no controller
      PopUps.snackbar(
        texto: '$type excluída com sucesso!',
        cor: Colors.green,
      );
    } catch (e) {
      debugPrint("Erro no hideNews: $e");
      PopUps.snackbar(
        texto: 'Não foi possível excluir essa $type no momento.',
        cor: Colors.red,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> reviewNews({
    required String newsId,
    required bool isApproved,
    required String reason,
    required String validator,
    required String creator,
    required String validatorName,
    required String newsType,
  }) async {
    // Impede auto-revisão
    if (validator == creator) {
      PopUps.snackbar(
        texto: 'Você não pode revisar sua própria matéria.',
        cor: Colors.red,
      );
      return;
    }

    try {
      isLoading(true);

      await _repository.reviewNews(
        newsId,
        isApproved,
        reason,
        validator,
        validatorName,
        newsType,
      );
      _repository
          .syncNewsHiveAndFirebase(); // Sincroniza os dados após atualização
      getAllNewsFromHive(); // Atualiza as listas no controller
      PopUps.snackbar(
        texto: isApproved
            ? 'Matéria aprovada com sucesso!'
            : 'Matéria rejeitada com sucesso!',
        cor: Colors.green,
      );
    } catch (e) {
      debugPrint("Erro no Controller (reviewNews): $e");
      PopUps.snackbar(
        texto: 'Não foi possível revisar a matéria.',
        cor: Colors.red,
      );
    } finally {
      isLoading(false);
    }
  }

  // Verifica se o usuário atual é o autor (p/ habilitar editar/excluir)
  bool canEdit(NewsModel news) {
    return user.email == news.createdBy;
  }

  bool canDelete(NewsModel news) {
    return user.role == 'editor' || user.role == 'admin';
  }

  bool canReReview(NewsModel news) {
    bool isEditorOrAdmin = user.role == 'editor' || user.role == 'admin';
    bool isNotAuthor = user.email != news.createdBy;
    bool isRevisableStatus = news.status == NewsStates.publicado ||
        news.status == NewsStates.emAnalise;

    return isEditorOrAdmin && isNotAuthor && isRevisableStatus;
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
