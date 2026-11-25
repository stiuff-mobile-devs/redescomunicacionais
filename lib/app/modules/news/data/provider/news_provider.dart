import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/mesh/security/model/public_key_package.dart';
import 'package:redescomunicacionais/app/modules/mesh/security/package_service.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_package_model.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_states.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/utils/components/friendly_exception.dart';
import 'package:redescomunicacionais/app/modules/utils/user/userRoles.dart';

class NewsProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions
      .instanceFor(region: 'southamerica-east1');
  late final OfflinePackageService offlinePackageService = OfflinePackageService();
  final String collectionPath = "news_test";
  final String publicKeyPackageKey = "publicKeyPackage";
  final String publicKeyPackagePath = "public_key_packages";
  final String collectionPackageNews = "news_packages";
  // Pacotes recebidos pela mesh sem assinatura válida: só retransmitidos,
  // nunca exibidos nem enviados à API
  final String collectionRelayPackages = "news_relay_packages";

  Future<Box<NewsPackageModel>> _newsBox() async =>
      Hive.isBoxOpen(collectionPackageNews)
          ? Hive.box<NewsPackageModel>(collectionPackageNews)
          : await Hive.openBox<NewsPackageModel>(collectionPackageNews);

  Future<Box<NewsPackageModel>> _relayBox() async =>
      Hive.isBoxOpen(collectionRelayPackages)
          ? Hive.box<NewsPackageModel>(collectionRelayPackages)
          : await Hive.openBox<NewsPackageModel>(collectionRelayPackages);

  //-----------------------------------------
  // Funções de manipulação Online (Firebase)
  //-----------------------------------------

  Future<void> _savePackageNewsToFirebase(NewsPackageModel news) async {
    try {
      final payload = news.toJson();
      await _functions.httpsCallable('uploadNewsPackage').call(payload);
    } on FirebaseFunctionsException catch (e) {
      throw Exception("Erro no Firebase Functions (${e.code}): ${e.message}");
    } catch (e) {
      throw Exception("Erro desconhecido ao salvar: $e");
    }
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?>
      getPublicNewsPaginatedFromFirebase({
    QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument,
  }) async {
    try {
      QueryDocumentSnapshot<Map<String, dynamic>>? nextLastDocument;

      Query<Map<String, dynamic>> query = _firestore
          .collection(collectionPath)
          .where('news.status', whereIn: [NewsStates.publicado])
          .orderBy('news.createdAt', descending: true)
          .limit(10);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        nextLastDocument = snapshot.docs.last;
      }

      await saveNewsPackageListToHive(_parseDocs(snapshot.docs));

      return nextLastDocument;
    } catch (e) {
      throw Exception("Erro ao buscar notícias públicas paginadas: $e");
    }
  }

  Future<void> getOuthersNewsFromFirebase(UserModel user) async {
    try {
      if (user.role != UserRoles.admin && user.role != UserRoles.editor) {
        throw Exception("Acesso negado: Usuário não é admin ou editor.");
      }

      Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> docs = {};

      List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [
        // Suas próprias privadas (Rascunho, Rejeitado, Deletado)
        _firestore
            .collection(collectionPath)
            .where('news.status', whereIn: [
              NewsStates.rascunho,
              NewsStates.rejeitado,
              NewsStates.deletado,
            ])
            .where('news.createdBy', isEqualTo: user.email)
            .get(),

        // Todas as matérias que aguardam análise no sistema
        _firestore
            .collection(collectionPath)
            .where('news.status', whereIn: [NewsStates.emAnalise]).get(),
      ];

      List<QuerySnapshot<Map<String, dynamic>>> snapshots =
          await Future.wait(futures);

      // Agrupa os resultados removendo duplicatas por ID
      for (var snapshot in snapshots) {
        for (var doc in snapshot.docs) {
          docs[doc.id] = doc;
        }
      }

      await saveNewsPackageListToHive(_parseDocs(docs.values));
    } catch (e) {
      throw Exception("Erro ao buscar matérias de administração: $e");
    }
  }

  // Converte os documentos um a um: um documento inválido é descartado (com
  // log) sem derrubar a lista inteira. Pacote sem notícia também é descartado.
  List<NewsPackageModel> _parseDocs(
      Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final List<NewsPackageModel> result = [];
    for (final doc in docs) {
      try {
        final data = doc.data();
        data['id'] = doc.id;
        final package = NewsPackageModel.fromJson(data);
        if (package.news != null) result.add(package);
      } catch (e) {
        debugPrint("Matéria ${doc.id} ignorada (dados inválidos): $e");
      }
    }
    return result;
  }

  Future<NewsPackageModel?> _getNewsByIdFromFirebase(String id) async {
    var doc = await _firestore.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return NewsPackageModel.fromJson(data);
  }

  
  //-----------------------------------------
  // Funções de manipulação local (Hive)
  //-----------------------------------------
  Future<NewsPackageModel?> getPackageNewsFromHive(String id) async {
    try {
      final box = await _newsBox();

      return box.get(id);
    } catch (e) {
      throw Exception("Erro ao buscar pacote de notícias: $e");
    }
  }

  Future<List<NewsPackageModel>> getAllPackageNewsFromHive() async {
    try {
      final box = await _newsBox();

      // Pega todos os valores da caixa e transforma em uma lista
      return box.values.toList();
    } catch (e) {
      throw Exception("Erro ao buscar todos os pacotes: $e");
    }
  }

  Future<void> saveNewsPackageInHive(NewsPackageModel package) async {
    try {
      final box = await _newsBox();

      //  salva ou atualiza se o ID já existir
      await box.put(package.id, package);
    } catch (e) {
      throw Exception("Erro ao salvar no Hive local: $e");
    }
  }

  Future<void> saveNewsPackageListToHive(
      List<NewsPackageModel> newsList) async {
    if (newsList.isEmpty) return;

    try {
      final box = await _newsBox();

      final Map<String, NewsPackageModel> newsMap = {};
      for (var news in newsList) {
        final key = news.id ?? news.news?.id ?? "";
        final local = box.get(key);

        // Não sobrescreve uma versão local mais nova (ex.: edição que ainda
        // não subiu pro Firebase) com a versão antiga vinda do servidor
        if (local != null && _isLocalNewer(local, news)) continue;

        newsMap[key] = news;
      }

      await box.putAll(newsMap);
    } catch (e) {
      throw Exception("Erro ao salvar dados no Hive local: $e");
    }
  }

  // Assina e grava uma versão alterada da matéria. A alteração é feita numa
  // cópia: se a assinatura falhar, o pacote guardado no Hive fica intacto
  // (o Hive devolve a mesma instância que mantém em memória).
  Future<void> _signAndSave(NewsPackageModel original, NewsModel changed) async {
    final resigned = await offlinePackageService.resignNewsPackage(
      NewsPackageModel(
        news: changed,
        signature: original.signature,
        email: original.email,
        lastUpdated: original.lastUpdated,
        isUploaded: original.isUploaded,
        id: original.id ?? changed.id,
      ),
    );
    if (resigned == null) {
      throw Exception('Falha ao assinar a matéria ${changed.id}.');
    }
  }

  // Soft delete (o status precisa se propagar pela mesh)
  Future<void> hideNews(String newsId, String status, String userEmail) async {
    final DateTime now = DateTime.now();

    try {
      final box = await _newsBox();
      final NewsPackageModel? package = box.get(newsId);
      final NewsModel? news = package?.news;
      if (package == null || news == null) {
        throw Exception('Notícia $newsId não encontrada no Hive local.');
      }

      final changed = news.copy()
        ..status = status
        ..excludedAt = now
        ..excludedBy = userEmail
        ..lastUpdated = now;

      await _signAndSave(package, changed);
    } on FriendlyException {
      rethrow; // ex.: assinatura ainda não ativada
    } catch (e) {
      debugPrint("Erro crítico ao atualizar Hive local: $e");
      throw Exception("Falha ao ocultar notícia.");
    }
  }

  // Apaga de verdade (só para rascunho, que nunca saiu do aparelho)
  Future<void> deleteNewsFromHive(String newsId) async {
    final box = await _newsBox();
    await box.delete(newsId);
  }

  // Grava uma nova versão do conteúdo/status montada pelo controller
  Future<void> updateNews(NewsModel updated) async {
    final box = await _newsBox();
    final NewsPackageModel? existing = box.get(updated.id);

    if (existing == null) {
      throw Exception('Notícia ${updated.id} não encontrada no Hive local.');
    }

    await _signAndSave(existing, updated);
  }

  Future<void> reviewNews({
    required String newsId,
    required bool isApproved,
    required String reason,
    required String validator,
    required String validatorName,
  }) async {
    final DateTime now = DateTime.now();

    try {
      final box = await _newsBox();
      final NewsPackageModel? package = box.get(newsId);
      final NewsModel? news = package?.news;

      if (package == null || news == null) {
        throw Exception('Notícia $newsId não encontrada no Hive local.');
      }

      final changed = news.copy()
        ..status = isApproved ? NewsStates.publicado : NewsStates.rejeitado
        ..lastUpdated = now;

      if (isApproved) {
        changed
          ..validatedAt = now
          ..validatedObservation = reason
          ..validatedBy = validator
          ..validatedByName = validatorName;
      } else {
        changed
          ..rejectedAt = now
          ..rejectedBy = validator
          ..rejectedObservation = reason;
      }

      await _signAndSave(package, changed);
    } on FriendlyException {
      rethrow; // ex.: assinatura ainda não ativada
    } catch (e) {
      debugPrint("Erro ao atualizar revisão no Hive: $e");
      throw Exception("Erro ao atualizar revisão no Hive");
    }
  }

  //-----------------------------------------
  // Pacotes de retransmissão (mesh)
  //-----------------------------------------

  Future<void> saveRelayPackage(NewsPackageModel package) async {
    final key = package.id ?? package.news?.id;
    if (key == null) return;
    final box = await _relayBox();
    await box.put(key, package);
  }

  Future<List<NewsPackageModel>> getAllRelayPackages() async {
    final box = await _relayBox();
    return box.values.toList();
  }

  Future<void> removeRelayPackage(String id) async {
    final box = await _relayBox();
    await box.delete(id);
  }

  //-----------------------------------------
  // Função de sincronização entre Hive e Firebase
  //-----------------------------------------

  // Busca o pacote de chaves na API, valida e salva no Hive se for mais novo.
  Future<void> _syncPublicKeysPackage() async {
    try {
      final PublicKeyPackage? apiPackage = await offlinePackageService
          .fetchPublicKeysPackageFromApi();

      if (apiPackage == null) {
        return;
      }

      final PublicKeyPackage? localPackage = await getPublicKeyPackage();
      if (localPackage == null ||
          apiPackage.timestamp.isAfter(localPackage.timestamp)) {
        await savePublicKeyPackage(apiPackage);
        // Chaves novas podem validar matérias que estavam só na retransmissão
        await offlinePackageService.revalidateRelayPackages();
      }
    } catch (e) {
      debugPrint("Erro ao sincronizar pacote de chaves públicas: $e");
    }
  }

  Future<void> syncNewsHiveAndFirebase(UserModel user) async {
    /*bool isAdminOrEditor =
        user.role == UserRoles.admin || user.role == UserRoles.editor;*/

    await _syncPublicKeysPackage();

    try {
      List<NewsPackageModel> hivePackageNewsList =
          await getAllPackageNewsFromHive();

      for (NewsPackageModel hiveNews in hivePackageNewsList) {
        // Rascunho fica só no aparelho, e excluída/rejeitada antiga não sobe
        if (!shouldUpload(hiveNews)) continue;

        try {
          NewsPackageModel? fbNews =
              await _getNewsByIdFromFirebase(hiveNews.news?.id ?? "");

          if (fbNews == null) {
            await _uploadAndMark(hiveNews);
          } else {
            // Ambas existem: compara as datas de modificação para ver quem ganha
            DateTime? fbDate = fbNews.lastUpdated;
            DateTime? hiveDate = hiveNews.lastUpdated;

            if (fbDate == null && hiveDate != null) {
              // Documento antigo no Firebase sem data no pacote: o local vence
              await _uploadAndMark(hiveNews);
            } else if (fbDate != null && hiveDate != null) {
              // Milissegundos: a mesma precisão do texto assinado
              final int fbMs = fbDate.millisecondsSinceEpoch;
              final int hiveMs = hiveDate.millisecondsSinceEpoch;

              if (fbMs > hiveMs) {
                await saveNewsPackageInHive(fbNews);
              } else if (hiveMs > fbMs) {
                await _uploadAndMark(hiveNews);
              }
            }
          }
        } catch (e) {
          debugPrint("Erro ao sincronizar a notícia ID ${hiveNews.id}: $e");
        }
      }
    } catch (e) {
      throw Exception("Erro fatal ao sincronizar Hive e Firebase: $e");
    }
  }

  // Envia o pacote à API e, com sucesso, marca isUploaded = true no Hive.
  // isUploaded não entra na assinatura, então o pacote continua válido.
  Future<void> _uploadAndMark(NewsPackageModel package) async {
    await _savePackageNewsToFirebase(package);

    final box = await _newsBox();
    final key = package.id ?? package.news?.id;
    if (key == null) return;

    // Só marca se o pacote local não mudou durante o envio
    final current = box.get(key);
    if (current != null && current.lastUpdated == package.lastUpdated) {
      await box.put(
        key,
        NewsPackageModel(
          news: current.news,
          signature: current.signature,
          email: current.email,
          lastUpdated: current.lastUpdated,
          isUploaded: true,
          id: current.id,
        ),
      );
    }
  }

  bool _isLocalNewer(NewsPackageModel local, NewsPackageModel remote) {
    final localDate = local.lastUpdated;
    final remoteDate = remote.lastUpdated;
    if (localDate == null) return false;
    if (remoteDate == null) return true;
    return localDate.millisecondsSinceEpoch > remoteDate.millisecondsSinceEpoch;
  }

  // Este pacote deve subir para a API? Rascunho nunca sobe, e matéria
  // excluída ou rejeitada há mais de 30 dias também não (será limpa do aparelho).
  bool shouldUpload(NewsPackageModel package) {
    final news = package.news;
    if (news == null || news.status == NewsStates.rascunho) return false;
    if (news.status == NewsStates.deletado ||
        news.status == NewsStates.rejeitado) {
      return _isLessThan30DaysOld(news.lastUpdated);
    }
    return true;
  }

  bool _isLessThan30DaysOld(DateTime? data) {
    final hoje = DateTime.now();

    if (data is DateTime) {
      final dataApenas = DateTime(data.year, data.month, data.day);
      final hojeApenas = DateTime(hoje.year, hoje.month, hoje.day);

      final diferencaEmDias = hojeApenas.difference(dataApenas).inDays;
      return diferencaEmDias >= 0 && diferencaEmDias < 30;
    }
    return false;
  }
  // ===========================================================================
  // GERENCIAMENTO DE PACOTES DE CHAVES PÚBLICAS
  // ===========================================================================

  Future<void> savePublicKeyPackage(PublicKeyPackage package) async {
    try {
      var box = Hive.isBoxOpen(publicKeyPackagePath)
          ? Hive.box<PublicKeyPackage>(publicKeyPackagePath)
          : await Hive.openBox<PublicKeyPackage>(publicKeyPackagePath);

      await box.put(publicKeyPackageKey, package);
    } catch (e) {
      throw Exception("Erro ao salvar pacote de chaves: $e");
    }
  }

  /// Recupera um pacote de chaves específico através do e-mail do remetente
  Future<PublicKeyPackage?> getPublicKeyPackage() async {
    try {
      var box = Hive.isBoxOpen(publicKeyPackagePath)
          ? Hive.box<PublicKeyPackage>(publicKeyPackagePath)
          : await Hive.openBox<PublicKeyPackage>(publicKeyPackagePath);

      return box.get(publicKeyPackageKey);
    } catch (e) {
      throw Exception("Erro ao buscar pacote de chaves: $e");
    }
  }

  /// Retorna a lista de chaves públicas de um e-mail.
  /// A primeira posição [0] é a chave pública atual, as seguintes são as antigas.
  Future<List<String>> getKeysListByEmail(String email) async {
    try {
      PublicKeyPackage? localKeyPackage = await getPublicKeyPackage();
      return List<String>.from(localKeyPackage?.keysByEmail(email) ?? []);
    } catch (e) {
      debugPrint("Erro ao processar lista de chaves para $email: $e");
      return [];
    }
  }
}
