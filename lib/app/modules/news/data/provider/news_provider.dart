import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_package.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/package_service.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_package_model.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_states.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
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

      List<NewsPackageModel> newsList = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return NewsPackageModel.fromJson(data);
      }).toList();

      await saveNewsPackageListToHive(newsList);

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

      // Mapeia o resultado final unificado
      List<NewsPackageModel> othersNewsList = docs.values.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return NewsPackageModel.fromJson(data);
      }).toList();

      await saveNewsPackageListToHive(othersNewsList);
    } catch (e) {
      throw Exception("Erro ao buscar matérias de administração: $e");
    }
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

  Future<void> hideNews(String newsId, String status, String userEmail) async {
    DateTime now = DateTime.now();

    try {
      final box = await _newsBox();

      NewsPackageModel? news = box.get(newsId);

      if (news != null) {
        news.news?.status = status;
        news.news?.excludedAt = now;
        news.news?.excludedBy = userEmail;
        news.news?.lastUpdated = now;
        final resigned = await offlinePackageService.resignNewsPackage(news);
        if (resigned == null) {
          throw Exception('Falha ao assinar a exclusão.');
        }
      }
    } catch (e) {
      debugPrint("Erro crítico ao atualizar Hive local: $e");
      throw Exception("Falha ao ocultar notícia.");
    }
  }

  Future<void> updateNews(
      String newsId, Map<String, dynamic> updatedData) async {
    try {
      final box = await _newsBox();

      NewsPackageModel? existingNews = box.get(newsId);

      if (existingNews == null) {
        throw Exception('Notícia não encontrada no Hive local.');
      }

      final mergedData = existingNews.news!.toFirebase()..addAll(updatedData);
      mergedData['id'] = newsId;

      // mergedData é o mapa da notícia, não do pacote: monta o NewsModel e
      // embrulha num pacote, senão o pacote fica sem notícia e nada é salvo
      final updatedNews = NewsPackageModel(
        news: NewsModel.fromMap(mergedData),
        signature: existingNews.signature,
        email: existingNews.email,
        lastUpdated: existingNews.lastUpdated,
        isUploaded: existingNews.isUploaded,
        id: existingNews.id ?? newsId,
      );

      final resigned =
          await offlinePackageService.resignNewsPackage(updatedNews);
      if (resigned == null) {
        throw Exception('Falha ao assinar e salvar a notícia atualizada.');
      }
    } catch (e) {
      throw Exception("Erro ao atualizar notícia no Hive local: $e");
    }
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
      final news = box.get(newsId);

      if (news == null) {
        throw Exception('Notícia $newsId não encontrada no Hive local.');
      }

      news.news?.status =
          isApproved ? NewsStates.publicado : NewsStates.rejeitado;
      news.news?.lastUpdated = now;

      if (isApproved) {
        news.news?.validatedAt = now;
        news.news?.validatedObservation = reason;
        news.news?.validatedBy = validator;
        news.news?.validatedByName = validatorName;
      } else {
        news.news?.rejectedAt = now;
        news.news?.rejectedBy = validator;
        news.news?.rejectedObservation = reason;
      }

      final resigned = await offlinePackageService.resignNewsPackage(news);
      if (resigned == null) {
        throw Exception('Falha ao assinar a revisão.');
      }
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
        // Rascunho fica só no aparelho: nunca vai para a API
        if (hiveNews.news?.status == NewsStates.rascunho) continue;

        try {
          NewsPackageModel? fbNews =
              await _getNewsByIdFromFirebase(hiveNews.news?.id ?? "");

          if (fbNews == null) {
            //Se a matéria Deletada ou Rejeitada tem mais de 30 dias não sobe pro firebase
            if ((hiveNews.news?.status == NewsStates.deletado ||
                    hiveNews.news?.status == NewsStates.rejeitado) &&
                !_isLessThan30DaysOld(hiveNews.news?.lastUpdated)) {
              continue;
            } else {
              await _uploadAndMark(hiveNews);
            }
          } else {
            // Ambas existem: compara as datas de modificação para ver quem ganha
            DateTime? fbDate = fbNews.lastUpdated;
            DateTime? hiveDate = hiveNews.lastUpdated;

            if (fbDate == null && hiveDate != null) {
              // Documento antigo no Firebase sem data no pacote: o local vence
              await _uploadAndMark(hiveNews);
            } else if (fbDate != null && hiveDate != null) {
              DateTime cleanFbDate = _trimDateTime(fbDate);
              DateTime cleanHiveDate = _trimDateTime(hiveDate);

              if (cleanFbDate.isAfter(cleanHiveDate)) {
                await saveNewsPackageInHive(fbNews);
              } else if (cleanHiveDate.isAfter(cleanFbDate)) {
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
    return _trimDateTime(localDate).isAfter(_trimDateTime(remoteDate));
  }

  DateTime _trimDateTime(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
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
