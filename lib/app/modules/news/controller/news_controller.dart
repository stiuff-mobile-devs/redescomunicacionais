import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/mesh/transport/nearby_service.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_form_data.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/utils/components/friendly_exception.dart';
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

    // Mostra na hora o que já está no aparelho (listas e contadores da
    // central), sem esperar a sincronização, que offline demora a desistir
    await _rebuildListsFromHive();
    if (!isAllListsEmpty()) initialLoadDone(true);

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
    // Aparelhos já conectados pela rede oportunista recebem a novidade sem
    // precisar reconectar
    if (Get.isRegistered<NearbyService>()) {
      Get.find<NearbyService>().announceToConnected();
    }
  }

  // Atualiza as listas da tela a partir do Hive (ex.: matéria recebida de um
  // aparelho vizinho), sem sincronizar com a nuvem
  Future<void> refreshFromHive() => _rebuildListsFromHive();

  // Há pacotes (que não são rascunho) esperando para subir?
  Future<bool> _hasPendingUploads() async {
    try {
      final packages = await _repository.getAllPackageNews();
      return packages
          .any((p) => p.isUploaded != true && _repository.shouldUpload(p));
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

  // ---------------------------------------------------------------------------
  // CRIAR, EDITAR E RASCUNHOS
  // ---------------------------------------------------------------------------
  // Rascunho fica só no aparelho. Salvar como rascunho uma matéria já enviada
  // cria uma CÓPIA (id novo) e a versão que circula não muda; o vínculo
  // cópia -> original fica no GetStorage. Ao enviar a cópia, o conteúdo vai
  // para a original (que volta para Em revisão) e a cópia é apagada.

  static const String _draftCopiesKey = 'draft_copies';

  Map<String, String> _draftCopies() {
    try {
      final raw = GetStorage().read<Map<dynamic, dynamic>>(_draftCopiesKey);
      if (raw == null) return {};
      return {
        for (final entry in raw.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: entry.value as String,
      };
    } catch (e) {
      debugPrint("Erro ao ler as cópias de rascunho: $e");
      return {};
    }
  }

  Future<void> _setDraftCopy(String copyId, String? originalId) async {
    final copies = _draftCopies();
    if (originalId == null) {
      copies.remove(copyId);
    } else {
      copies[copyId] = originalId;
    }
    await GetStorage().write(_draftCopiesKey, copies);
  }

  // Este rascunho é cópia de uma matéria já enviada?
  bool isDraftCopy(NewsModel news) =>
      news.status == NewsStates.rascunho && _draftCopies().containsKey(news.id);

  // Usuário da sessão com e-mail (exigido para assinar e como autor)
  UserModel _sessionUser() {
    final email = user.email;
    if (email == null || email.isEmpty || user.role == UserRoles.guest) {
      throw const FriendlyException(LocaleKeys.loginAgain,
          details: 'Usuário sem e-mail na sessão.');
    }
    return user;
  }

  Future<NewsModel> _editableNews(String newsId) async {
    final NewsModel? news = (await _repository.getPackageNews(newsId))?.news;
    if (news == null || !canEdit(news)) {
      throw FriendlyException(LocaleKeys.newsNotEditable,
          details: 'Matéria $newsId inexistente ou sem permissão.');
    }
    return news;
  }

  Future<NewsModel?> getNewsForEdit(String newsId) async {
    final NewsModel? news = (await _repository.getPackageNews(newsId))?.news;
    if (news == null || !canEdit(news)) return null;
    return news;
  }

  Future<void> _createNews(NewsFormData form, String status) async {
    final session = _sessionUser();
    final now = DateTime.now();
    final news = NewsModel(
      title: form.title,
      subtitle: form.subtitle,
      body: form.body,
      cities: form.cities,
      categories: form.categories,
      urlImages: form.urlImages,
      videoUrl: form.videoUrl,
      type: form.type,
      status: status,
      author: session.name ?? '',
      createdBy: session.email!,
      createdAt: now,
      lastUpdated: now,
      collaborators: form.collaborators,
    );
    await _repository.saveNewsToPackage(news, session.email!);
  }

  // Aplica o formulário numa cópia da matéria, com novo status e datas, e grava assinado
  Future<void> _saveEdited(NewsModel base, NewsFormData form, String status) async {
    final now = DateTime.now();
    final changed = base.copy()
      ..status = status
      ..editedAt = now
      ..lastUpdated = now;
    form.applyTo(changed);
    await _repository.updateNews(changed);
  }

  // Salvar rascunho. Devolve true quando criou uma cópia de matéria já enviada.
  Future<bool> saveDraft(NewsFormData form, {String? editingId}) async {
    isLoading(true);
    try {
      if (editingId == null) {
        await _createNews(form, NewsStates.rascunho);
        return false;
      }

      final existing = await _editableNews(editingId);
      if (existing.status == NewsStates.rascunho) {
        await _saveEdited(existing, form, NewsStates.rascunho);
        return false;
      }

      // Matéria já enviada: cria a cópia em rascunho e guarda o vínculo
      final session = _sessionUser();
      final now = DateTime.now();
      final copy = existing.copy();
      form.applyTo(copy);
      final draft = NewsModel(
        title: copy.title,
        subtitle: copy.subtitle,
        body: copy.body,
        cities: copy.cities,
        categories: copy.categories,
        urlImages: copy.urlImages,
        videoUrl: copy.videoUrl,
        type: copy.type,
        status: NewsStates.rascunho,
        author: existing.author,
        createdBy: existing.createdBy,
        createdAt: now,
        lastUpdated: now,
        collaborators: copy.collaborators,
      );
      await _repository.saveNewsToPackage(draft, session.email!);
      await _setDraftCopy(draft.id, existing.id);
      return true;
    } finally {
      await onLocalNewsChanged();
      isLoading(false);
    }
  }

  // Enviar para revisão (criar, rascunho, cópia de rascunho ou matéria já enviada)
  Future<void> submitForReview(NewsFormData form, {String? editingId}) async {
    isLoading(true);
    try {
      if (editingId == null) {
        await _createNews(form, NewsStates.emAnalise);
        return;
      }

      final existing = await _editableNews(editingId);
      final String? originalId = existing.status == NewsStates.rascunho
          ? _draftCopies()[existing.id]
          : null;

      if (originalId == null) {
        await _saveEdited(existing, form, NewsStates.emAnalise);
        return;
      }

      // Cópia de rascunho: o conteúdo vai para a original, se ela ainda existir
      final NewsModel? original =
          (await _repository.getPackageNews(originalId))?.news;
      if (original != null &&
          original.status != NewsStates.deletado &&
          canEdit(original)) {
        await _saveEdited(original, form, NewsStates.emAnalise);
        await _repository.deleteNewsFromHive(existing.id);
      } else {
        // Original excluída ou fora do aparelho: a cópia vira matéria nova
        await _saveEdited(existing, form, NewsStates.emAnalise);
      }
      await _setDraftCopy(existing.id, null);
    } finally {
      await onLocalNewsChanged();
      isLoading(false);
    }
  }

  // Mensagem de sucesso; sem internet, avisa que o envio fica pendente
  void notifySaved(String onlineMessage, {bool localOnly = false}) {
    final bool online =
        homeController.connectionsController.isInternetConnected.value;
    if (online || localOnly) {
      AppPopups.success(onlineMessage);
    } else {
      AppPopups.info(LocaleKeys.savedOnDeviceWillSync.tr);
    }
  }

  // ---------------------------------------------------------------------------
  // EXCLUIR E REVISAR
  // ---------------------------------------------------------------------------

  Future<void> hideNews(NewsModel news) async {
    if (!canDelete(news)) {
      AppPopups.warning(LocaleKeys.onlyAuthorCanDelete.tr);
      return;
    }

    isLoading(true);

    try {
      if (news.status == NewsStates.rascunho) {
        // Rascunho nunca saiu do aparelho: apaga de verdade
        await _repository.deleteNewsFromHive(news.id);
        await _setDraftCopy(news.id, null);
        await onLocalNewsChanged();
        AppPopups.success(LocaleKeys.draftDeletedSuccess.tr);
        return;
      }

      await _repository.hideNews(
          news.id, NewsStates.deletado, _sessionUser().email!);
      await onLocalNewsChanged();
      notifySaved(LocaleKeys.typeDeletedSuccess
          .trParams({'type': NewsLabels.type(news.type)}));
    } on FriendlyException catch (e) {
      debugPrint("Erro no hideNews: $e");
      AppPopups.warning(e.messageKey.tr);
    } catch (e) {
      debugPrint("Erro no hideNews: $e");
      AppPopups.error(LocaleKeys.typeDeleteError
          .trParams({'type': NewsLabels.type(news.type).toLowerCase()}));
    } finally {
      isLoading(false);
    }
  }

  Future<void> reviewNews(
      NewsModel news, bool isApproved, String reason) async {
    // As mesmas regras do botão, conferidas também aqui
    if (!canReReview(news)) {
      AppPopups.warning(LocaleKeys.cannotReviewOwnNews.tr);
      return;
    }
    if (isApproved && news.status == NewsStates.publicado) return;

    try {
      isLoading(true);

      final session = _sessionUser();
      await _repository.reviewNews(
        news.id,
        isApproved,
        reason,
        session.email!,
        session.name ?? '',
      );
      await onLocalNewsChanged();
      notifySaved(isApproved
          ? LocaleKeys.newsApprovedSuccess.tr
          : LocaleKeys.newsRejectedSuccess.tr);
    } on FriendlyException catch (e) {
      debugPrint("Erro no Controller (reviewNews): $e");
      AppPopups.warning(e.messageKey.tr);
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

  // Só o autor exclui; matéria já excluída não mostra o botão de novo
  bool canDelete(NewsModel news) {
    return user.email == news.createdBy &&
        news.status != NewsStates.deletado;
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

  // Abre o formulário em modo edição (ele carrega a matéria do Hive pelo id)
  void openEditNews(NewsModel news) {
    Get.toNamed(Routes.EDIT_NEWS, arguments: {'newsId': news.id});
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
