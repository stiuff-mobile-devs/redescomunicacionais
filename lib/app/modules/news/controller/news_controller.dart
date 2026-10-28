import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_package_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/utils/components/popups.dart';

class NewsController extends GetxController {
  final NewsRepository _repository = NewsRepository();
  final UserRepository _userRepository = UserRepository();

  late HomeController homeController;
  QuillController quillController = QuillController.basic();

  UserModel user = UserModel.empty();

  QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument;

  RxList<NewsModel> inAnalysisNewsList = <NewsModel>[].obs;
  RxList<NewsModel> myDraftsList = <NewsModel>[].obs;
  RxList<NewsModel> rejectedNewsList = <NewsModel>[].obs;
  RxList<NewsModel> deletedNewsList = <NewsModel>[].obs;
  RxList<NewsModel> publishedNewsList = <NewsModel>[].obs;

  late NewsModel selectedNews;
  RxBool isLoading = false.obs;
  // Fica true quando a primeira busca termina (com sucesso, erro ou timeout)
  RxBool initialLoadDone = false.obs;
  RxnInt selectedCardIndex = RxnInt();

  static const Duration fetchTimeout = Duration(seconds: 10);

  @override
  onInit() async {
    super.onInit();
    homeController = Get.find<HomeController>();
    try {
      user = await _userRepository.getCurrentUserFromHive();
    } catch (e) {
      debugPrint("Erro ao carregar usuário: $e");
    }
    await syncNews(null);
  }

  Future<void> syncNews(
      QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc) async {
    isLoading(true);
    try {
      await Future(() async {
        try {
          await _repository.syncNewsHiveAndFirebase(user);
        } catch (e) {
          debugPrint("Erro ao sincronizar notícias: $e");
        }
        await getPublicNewsFromHive(lastDoc);
        await getOuthersNewsFromHive();
      }).timeout(fetchTimeout);
    } on TimeoutException {
      debugPrint("Timeout ao buscar notícias (${fetchTimeout.inSeconds}s)");
    } catch (e) {
      debugPrint("Erro ao sincronizar notícias: $e");
    } finally {
      isLoading(false);
      initialLoadDone(true);
    }
  }

  Future<void> getMoreNews() async {
    if (lastDocument == null) {
      return; // Não há mais notícias para carregar
    }
    await getPublicNewsFromHive(lastDocument, isGetMoreNews: true);
  }

  Future<void> getOuthersNewsFromHive() async {
    try {
      isLoading(true);
      // So admin e editor veem as listas de análise, rascunho, rejeitado e deletado
      if (user.role == UserRoles.admin || user.role == UserRoles.editor) {
        await _repository.getOuthersNewsFromFirebase(
            user); // Atualiza o Hive com os dados do Firebase

        List<NewsPackageModel> outhersNews =
            await _repository.getAllPackageNews();

        outhersNews.sort((a, b) {
          final dateA = a.news?.lastUpdated;
          final dateB = b.news?.lastUpdated;

          final compareB = dateB ?? DateTime.fromMillisecondsSinceEpoch(0);
          final compareA = dateA ?? DateTime.fromMillisecondsSinceEpoch(0);

          return compareB.compareTo(compareA);
        });

        inAnalysisNewsList.assignAll(
          outhersNews
              .where((item) => item.news?.status == NewsStates.emAnalise)
              .map((item) => item.news)
              .whereType<NewsModel>(),
        );

        myDraftsList.assignAll(
          outhersNews
              .where((item) => item.news?.status == NewsStates.rascunho)
              .map((item) => item.news)
              .whereType<NewsModel>(),
        );

        rejectedNewsList.assignAll(
          outhersNews
              .where((item) => item.news?.status == NewsStates.rejeitado)
              .map((item) => item.news)
              .whereType<NewsModel>(),
        );

        deletedNewsList.assignAll(
          outhersNews
              .where((item) => item.news?.status == NewsStates.deletado)
              .map((item) => item.news)
              .whereType<NewsModel>(),
        );
      }
    } catch (e) {
      debugPrint("Erro no Controller (Hive): $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> getPublicNewsFromHive(
      QueryDocumentSnapshot<Map<String, dynamic>>? ld,
      {bool isGetMoreNews = false}) async {
    try {
      if (!isGetMoreNews) {
        isLoading(true);
      }
      lastDocument = await _repository.getPublicNewsPaginatedFromFirebase(
          ld); // Atualiza o Hive com os dados do Firebase e obtém o próximo ponteiro de paginação
      List<NewsPackageModel> publicNews = await _repository.getAllPackageNews();

      publicNews.sort((a, b) {
        final dateA = a.news?.createdAt;
        final dateB = b.news?.createdAt;
        final compareB = dateB ?? DateTime.fromMillisecondsSinceEpoch(0);
        final compareA = dateA ?? DateTime.fromMillisecondsSinceEpoch(0);

        return compareB.compareTo(compareA);
      });

      publishedNewsList.assignAll(
        publicNews
            .where((item) => item.news?.status == NewsStates.publicado)
            .map((item) => item.news)
            .whereType<NewsModel>(),
      );
    } catch (e) {
      debugPrint("Erro no Controller (Hive): $e");
    } finally {
      isLoading(false);
    }
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
    List<String> collaborators,
  ) async {
    isLoading(true);

    try {
      UserModel user = await _userRepository.getCurrentUserFromHive();

      NewsModel news = NewsModel(
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
        collaborators: collaborators,
      );

      await _repository.saveNewsToPackage(news, user.email!);

      await syncNews(null);

    } catch (e) {
      throw Exception("Erro ao salvar notícia: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> hideNews({
    required String newsId,
    required String status,
    required String userEmail,
    required String type,
    required String creator,
  }) async {
    if (creator != userEmail) {
      PopUps.snackbar(
        texto: 'Você não pode revisar sua própria matéria.',
        cor: Colors.red,
      );
      return;
    }

    isLoading(true);

    try {
      await _repository.hideNews(newsId, status, userEmail);
      await syncNews(null);
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
      await syncNews(null);
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

  bool canEdit(NewsModel news) {
    return user.email == news.createdBy;
  }

  bool canDelete(NewsModel news) {
    return user.email == news.createdBy;
  }

  bool canReReview(NewsModel news) {
    bool isEditorOrAdmin =
        user.role == UserRoles.editor || user.role == UserRoles.admin;
    bool isNotAuthor = user.email != news.createdBy;
    bool isRevisableStatus = news.status == NewsStates.publicado ||
        news.status == NewsStates.emAnalise;

    return isEditorOrAdmin && isNotAuthor && isRevisableStatus;
  }

  bool isAllListsEmpty() {
    return publishedNewsList.isEmpty &&
        inAnalysisNewsList.isEmpty &&
        myDraftsList.isEmpty &&
        rejectedNewsList.isEmpty &&
        deletedNewsList.isEmpty;
  }

  bool isSelected(int index) => selectedCardIndex.value == index;

  void toggleSelected(int index) {
    if (selectedCardIndex.value == index) {
      selectedCardIndex.value = null;
    } else {
      selectedCardIndex.value = index;
    }
  }

  // Mapeamento city -> asset path para fallback de imagens
  final Map<String, String> _cityImageAssets = {
    'São Sebastião do Alto': 'assets/images/cidades/saosebastiaodoalto.jpg',
    'Macuco': 'assets/images/cidades/macuco.jpg',
    'Rio das Flores': 'assets/images/cidades/riodasflores.jpg',
    'Comendador Levy Gasparian': 'assets/images/cidades/levygasparian.jpg',
    'Laje do Muriaé': 'assets/images/cidades/lajedomuriae.jpg',
    'São José de Ubá': 'assets/images/cidades/saojosedeuba.jpg',
    // add more or a 'default' entry
    'default': 'assets/images/cidades/default_city.jpg',
  };

  // Retorna o path do asset JPG para a cidade dada
  String getCityImageAsset(String? city) {
    final key = (city == null || city.isEmpty) ? 'default' : city;
    return _cityImageAssets[key] ?? _cityImageAssets['default']!;
  }

  // Abre a página de detalhe
  void openNews(NewsModel news) {
    selectedNews = news;
    Get.toNamed(Routes.NEWS_PAGE);
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

  void startQuillController() {
    // Carrega o conteúdo Delta no controller
    try {
      if (selectedNews.body.isNotEmpty) {
        final deltaJson = jsonDecode(selectedNews.body);
        final document = Document.fromJson(deltaJson);
        quillController = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } catch (e) {
      // Se falhar ao decodificar, usa texto simples
      quillController = QuillController.basic();
      quillController.document.insert(0, selectedNews.body);
    }
  }

  List<NewsModel> getNewsForCurrentMode() {
    if (homeController.isDeletedMode.value) {
      return deletedNewsList.toList();
    }

    if (homeController.isRejectedMode.value) {
      return rejectedNewsList.toList();
    }

    if (homeController.isRevisionMode.value) {
      return inAnalysisNewsList.toList();
    }

    if (homeController.isDraftMode.value) {
      return myDraftsList.toList();
    }
    return publishedNewsList.toList();
  }
}
