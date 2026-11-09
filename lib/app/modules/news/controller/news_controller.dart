import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_labels.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_list_mode.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_states.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:redescomunicacionais/app/modules/utils/user/userRoles.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

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

  static const Duration fetchTimeout = Duration(seconds: 30);

  @override
  onInit() async {
    super.onInit();
    homeController = Get.find<HomeController>();
    try {
      user = await _userRepository.getCurrentUserFromHive();
    } catch (e) {
      debugPrint("Erro ao carregar usuário: $e");
    }
    // Reenvia o que ficou pendente quando a internet volta
    ever<bool>(homeController.connectionsController.isInternetConnected,
        (connected) async {
      if (connected && await _hasPendingUploads()) requestSync();
    });

    await requestSync();
  }

  // ---------------------------------------------------------------------------
  // SINCRONIZAÇÃO (offline first)
  // ---------------------------------------------------------------------------
  // As ações gravam no Hive e atualizam a tela na hora; a sincronização com a
  // nuvem roda depois, uma de cada vez. Se pedirem outra durante uma em
  // andamento, ela roda mais uma vez no final (em vez de rodar em paralelo).

  Future<void>? _currentSync;
  bool _syncAgain = false;

  Future<void> requestSync() {
    if (_currentSync != null) {
      _syncAgain = true;
      return _currentSync!;
    }
    _currentSync = _runSyncLoop().whenComplete(() => _currentSync = null);
    return _currentSync!;
  }

  Future<void> _runSyncLoop() async {
    do {
      _syncAgain = false;
      await syncNews(null);
    } while (_syncAgain);
  }

  // Depois de uma alteração local: atualiza as listas e sincroniza em segundo
  // plano, sem travar a tela (funciona offline)
  Future<void> onLocalNewsChanged() async {
    await _rebuildListsFromHive();
    unawaited(requestSync());
  }

  // Há pacotes (que não são rascunho) esperando para subir?
  Future<bool> _hasPendingUploads() async {
    try {
      final packages = await _repository.getAllPackageNews();
      return packages.any((p) =>
          p.isUploaded != true && p.news?.status != NewsStates.rascunho);
    } catch (_) {
      return false;
    }
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
      if (_isEditorOrAdmin) {
        await _repository.getOuthersNewsFromFirebase(
            user); // Atualiza o Hive com os dados do Firebase
      }
    } catch (e) {
      debugPrint("Erro ao buscar matérias editoriais: $e");
    } finally {
      await _rebuildListsFromHive();
      isLoading(false);
    }
  }

  bool get _isEditorOrAdmin =>
      user.role == UserRoles.admin || user.role == UserRoles.editor;

  // Monta todas as listas da tela a partir do Hive (sem rede)
  Future<void> _rebuildListsFromHive() async {
    try {
      final List<NewsModel> all = (await _repository.getAllPackageNews())
          .map((item) => item.news)
          .whereType<NewsModel>()
          .toList();

      DateTime orEpoch(DateTime? d) =>
          d ?? DateTime.fromMillisecondsSinceEpoch(0);

      // Feed: mais recentes primeiro pela data de criação
      final published = all
          .where((n) => n.status == NewsStates.publicado)
          .toList()
        ..sort((a, b) => orEpoch(b.createdAt).compareTo(orEpoch(a.createdAt)));
      publishedNewsList.assignAll(published);

      if (!_isEditorOrAdmin) return;

      // Listas editoriais: mais recentes primeiro pela última alteração
      all.sort(
          (a, b) => orEpoch(b.lastUpdated).compareTo(orEpoch(a.lastUpdated)));

      // Em revisão: todas (qualquer editor revisa)
      inAnalysisNewsList.assignAll(
          all.where((n) => n.status == NewsStates.emAnalise));

      // Rascunhos, rejeitadas e excluídas: só as do próprio autor (o Hive
      // também guarda matérias de outros, ex.: as que este editor rejeitou)
      bool mine(NewsModel n) => n.createdBy == user.email;
      myDraftsList.assignAll(
          all.where((n) => n.status == NewsStates.rascunho && mine(n)));
      rejectedNewsList.assignAll(
          all.where((n) => n.status == NewsStates.rejeitado && mine(n)));
      deletedNewsList.assignAll(
          all.where((n) => n.status == NewsStates.deletado && mine(n)));
    } catch (e) {
      debugPrint("Erro ao montar as listas a partir do Hive: $e");
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
    } catch (e) {
      debugPrint("Erro ao buscar o feed: $e");
    } finally {
      // Mesmo sem internet, mostra o que está no Hive
      await _rebuildListsFromHive();
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

      await onLocalNewsChanged();

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
      AppPopups.warning(LocaleKeys.onlyAuthorCanDelete.tr);
      return;
    }

    isLoading(true);

    try {
      await _repository.hideNews(newsId, status, userEmail);
      await onLocalNewsChanged();
      AppPopups.success(LocaleKeys.typeDeletedSuccess
          .trParams({'type': NewsLabels.type(type)}));
    } catch (e) {
      debugPrint("Erro no hideNews: $e");
      AppPopups.error(LocaleKeys.typeDeleteError
          .trParams({'type': NewsLabels.type(type).toLowerCase()}));
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
  }) async {
    // Impede auto-revisão
    if (validator == creator) {
      AppPopups.warning(LocaleKeys.cannotReviewOwnNews.tr);
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
      );
      await onLocalNewsChanged();
      AppPopups.success(isApproved
          ? LocaleKeys.newsApprovedSuccess.tr
          : LocaleKeys.newsRejectedSuccess.tr);
    } catch (e) {
      debugPrint("Erro no Controller (reviewNews): $e");
      AppPopups.error(LocaleKeys.newsReviewError.tr);
    } finally {
      isLoading(false);
    }
  }

  // Matéria excluída não volta a ser editada (o soft delete é definitivo)
  bool canEdit(NewsModel news) {
    return user.email == news.createdBy &&
        news.status != NewsStates.deletado;
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

  // Lista de matérias do filtro exibido na Home
  List<NewsModel> getNewsForMode(NewsListMode mode) {
    switch (mode) {
      case NewsListMode.deleted:
        return deletedNewsList.toList();
      case NewsListMode.rejected:
        return rejectedNewsList.toList();
      case NewsListMode.revision:
        return inAnalysisNewsList.toList();
      case NewsListMode.drafts:
        return myDraftsList.toList();
      case NewsListMode.published:
        return publishedNewsList.toList();
    }
  }
}
