import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomeController get homeController => Get.find<HomeController>();

  var newsList = <NewsModel>[].obs;

  RxBool isLoading = false.obs;
  RxnInt selectedCardIndex = RxnInt();

  @override
  onInit() async {
    super.onInit();
    userController = Get.find<UserController>();
    user = await userController.getCurrentUser();
    await _repository.syncHiveAndFirebase(); // Sincroniza dados ao iniciar
    getNewsFromHive();
  }

  // Add news - save to both Hive and Firebase
  Future<void> addNews(
    String title,
    String? subtitle,
    List<String> cities,
    List<String> categories,
    String body,
    List<String> urlImages,
    String author,
    String email,
    String createdAt,
    String type,
    String status,
    String? videoUrl,
  ) async {
    isLoading(true);

    bool savedOnFirebase = false;
    bool savedOnHive = false;

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

      // 2. Tentar salvar no Firebase
      try {
        await _repository.saveNewsToFirebase(news);
        savedOnFirebase = true;
      } catch (e) {
        debugPrint("Firebase falhou: $e. Sincronização pendente.");
        // Não lançamos erro aqui, apenas logamos.
      }
      // 3. Tentar salvar no Hive
      try {
        await _repository.saveNewsToHive(news);
        savedOnHive = true;
      } catch (e) {
        debugPrint("Hive falhou: $e.");
      }

      // 4. Lógica de decisão: só avisa erro se NENHUM dos dois funcionou
      if (!savedOnFirebase && !savedOnHive) {
        throw Exception(
            "Não foi possível salvar os dados localmente nem na nuvem.");
      }
    } catch (e) {
      throw Exception("Erro ao salvar notícia: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> getNewsFromFirebase() async {
    try {
      isLoading(true);

      //  Busca os dados (que já devem vir ordenados do Repository)
      final fetchedNews = await _repository.getNewsFromFirebase();

      newsList.assignAll(
          fetchedNews); // Se estiver usando GetX, o assignAll é mais eficiente
    } catch (e) {
      debugPrint("Erro ao buscar notícias: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> getNewsFromHive() async {
    try {
      isLoading(true);

      //  O Repository já entrega a lista filtrada e ordenada!
      final fetchedNews = await _repository.getNewsFromHive();

      //  Apenas atribui à lista reativa
      newsList.assignAll(fetchedNews);
    } catch (e) {
      debugPrint("Erro no Controller (Hive): $e");
    } finally {
      isLoading(false);
    }
  }

  Future<String> hideNews({
    required String newsId,
    required String status,
    required String userEmail,
    required String authorEmail,
    required String type,
  }) async {
    //  Verificação de permissão logo no início
    if (userEmail != authorEmail) {
      PopUps.snackbar(
        texto: 'Você não tem permissão para excluir esta $type.',
        cor: Colors.red,
      );
      return "sem_permissao";
    }

    try {
      isLoading(true);

      String result = await _repository.hideNews(newsId, status, userEmail);

      if (result == "success") {
        // Remove da lista reativa para sumir da tela instantaneamente
        newsList.removeWhere((news) => news.id == newsId);

        PopUps.snackbar(
          texto: '$type excluída com sucesso!',
          cor: Colors.green,
        );
        return "success";
      } else {
        // Caso o repositório retorne algo diferente de sucesso sem lançar exception
        PopUps.snackbar(
          texto: 'Erro ao tentar excluir a $type.',
          cor: Colors.red,
        );
        return "error";
      }
    } catch (e) {
      debugPrint("Erro no hideNews: $e");
      PopUps.snackbar(
        texto: 'Não foi possível excluir essa $type no momento.',
        cor: Colors.red,
      );
      return "error";
    } finally {
      isLoading(false);
    }
  }

  List<NewsModel> getValidNews() {
    return _filterByStatus(NewsStates.publicado);
  }

  List<NewsModel> getInAnalysis() {
    return _filterByStatus(NewsStates.emAnalise);
  }

  List<NewsModel> getMyDrafts() {
    return _filterByStatus(NewsStates.rascunho, onlyMine: true);
  }

  List<NewsModel> getRejectedNews() {
    return _filterByStatus(NewsStates.rejeitado, onlyMine: true);
  }

  List<NewsModel> getDeletedNews() {
    return _filterByStatus(NewsStates.deletado, onlyMine: true);
  }

  // --- FUNÇÃO DE FILTRAGEM ---
  // Centraliza a lógica para facilitar a manutenção
  List<NewsModel> _filterByStatus(String status, {bool onlyMine = false}) {
    return newsList.where((news) {
      // 1. Filtro de Status
      if (news.status != status) return false;

      // 2. Filtro de Autoria (se solicitado)
      if (onlyMine && news.createdBy != user.email) return false;

      // 3. Filtro de Imagem (regra global de renderização)
      return _hasRenderableImage(news);
    }).toList();
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

  // Verifica se o usuário atual é o autor (p/ habilitar editar/excluir)
  bool canEdit(NewsModel news) {
    return user.email == news.createdBy;
  }

  bool canDelete(NewsModel news) {
    return user.email == news.createdBy;
  }

  bool canReReview(NewsModel news) {
    final isEditorOrAdmin = user.role == 'editor' || user.role == 'admin';
    final isNotAuthor = user.email != news.createdBy;
    final isRevisableStatus = news.status == NewsStates.publicado ||
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

  Future<void> reviewNews({
    required String newsId,
    required bool isApproved,
    required String reason,
    required String validator,
    required String creator,
    required String validatorName,
    required String newsType,
  }) async {
    // 1. Regra de negócio: Impede auto-revisão
    if (validator == creator) {
      PopUps.snackbar(
        texto: 'Você não pode revisar sua própria matéria.',
        cor: Colors.red,
      );
      return;
    }

    try {
      isLoading(true);

      // 2. Chama o Repository (que agora atualiza Firebase e Hive com os try-catchs)
      await _repository.reviewNews(
        newsId,
        isApproved,
        reason,
        validator,
        validatorName,
        newsType,
      );

      int index = newsList.indexWhere((n) => n.id == newsId);
      if (index != -1) {
        newsList[index].status =
            isApproved ? NewsStates.publicado : NewsStates.rejeitado;
      }

      // 4. Sincroniza o resto do app
      homeController.forceRecreate();

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
}
