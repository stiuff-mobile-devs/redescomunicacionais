import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_model.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_package.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/package_service.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_package_model.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';

class NewsProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OfflinePackageService offlinePackageService = OfflinePackageService();
  final String collectionPath = "news_test";
  final String publicKeyPackageKey = "publicKeyPackage";
  final String publicKeyPackagePath = "public_key_packages";
  final String collectionPackageNews = "news_packages";

  //-----------------------------------------
  // Funções de manipulação Online (Firebase)
  //-----------------------------------------

  Future<void> _savePackageNewsToFirebase(NewsPackageModel news) async {
    try {
      await _firestore.collection(collectionPath).doc(news.id).set(
            news.toFirebase(),
            SetOptions(merge: true),
          );
    } on FirebaseException catch (e) {
      throw Exception("Erro no Firebase (${e.code}): ${e.message}");
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
      var box = Hive.isBoxOpen(collectionPackageNews)
          ? Hive.box<NewsPackageModel>(collectionPackageNews)
          : await Hive.openBox<NewsPackageModel>(collectionPackageNews);

      return box.get(id);
    } catch (e) {
      throw Exception("Erro ao buscar pacote de notícias: $e");
    }
  }

  Future<List<NewsPackageModel>> getAllPackageNewsFromHive() async {
    try {
      var box = Hive.isBoxOpen(collectionPackageNews)
          ? Hive.box<NewsPackageModel>(collectionPackageNews)
          : await Hive.openBox<NewsPackageModel>(collectionPackageNews);

      // Pega todos os valores da caixa e transforma em uma lista
      return box.values.toList();
    } catch (e) {
      throw Exception("Erro ao buscar todos os pacotes: $e");
    }
  }

  Future<void> saveNewsPackageInHive(NewsPackageModel package) async {
    try {
      var box = Hive.isBoxOpen(collectionPackageNews)
          ? Hive.box<NewsPackageModel>(collectionPackageNews)
          : await Hive.openBox<NewsPackageModel>(collectionPackageNews);

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
      var box = Hive.isBoxOpen(collectionPackageNews)
          ? Hive.box<NewsPackageModel>(collectionPackageNews)
          : await Hive.openBox<NewsPackageModel>(collectionPackageNews);

      final Map<String, NewsPackageModel> newsMap = {
        for (var news in newsList) news.news?.id ?? "": news
      };

      await box.putAll(newsMap);
    } catch (e) {
      throw Exception("Erro ao salvar dados no Hive local: $e");
    }
  }

  Future<void> hideNews(String newsId, String status, String userEmail) async {
    DateTime now = DateTime.now();

    try {
      final box = Hive.isBoxOpen(collectionPackageNews)
          ? Hive.box<NewsPackageModel>(collectionPackageNews)
          : await Hive.openBox<NewsPackageModel>(collectionPackageNews);

      NewsPackageModel? news = box.get(newsId);

      if (news != null) {
        news.news?.status = status;
        news.news?.excludedAt = now;
        news.news?.excludedBy = userEmail;
        news.news?.lastUpdated = now;
        offlinePackageService.resignNewsPackage(news);
      }
    } catch (e) {
      debugPrint("Erro crítico ao atualizar Hive local: $e");
      throw Exception("Falha ao ocultar notícia.");
    }
  }

  Future<void> updateNews(
      String newsId, Map<String, dynamic> updatedData) async {
    try {
      final box = Hive.isBoxOpen(collectionPackageNews)
          ? Hive.box<NewsPackageModel>(collectionPackageNews)
          : await Hive.openBox<NewsPackageModel>(collectionPackageNews);

      NewsPackageModel? existingNews = box.get(newsId);

      if (existingNews == null) {
        throw Exception('Notícia não encontrada no Hive local.');
      }

      final mergedData = existingNews.news!.toFirebase()..addAll(updatedData);
      mergedData['id'] = newsId;

      final updatedNews = NewsPackageModel.fromJson(mergedData);
      offlinePackageService.resignNewsPackage(updatedNews);

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
    required String newsType,
  }) async {
    DateTime now = DateTime.now();
    bool isDeleted = newsType == NewsStates.deletado;
    String status = isApproved ? NewsStates.publicado : NewsStates.rejeitado;

    final Map<String, dynamic> updates = {
      'status': isDeleted ? NewsStates.deletado : status,
      'type': newsType,
    };

    try {
      if (Hive.isBoxOpen(collectionPackageNews)) {
        var box = Hive.box<NewsPackageModel>(collectionPackageNews);
        var news = box.get(newsId);

        if (news != null) {
          news.news?.status = updates['status'];
          news.news?.type = updates['type'];
          news.news?.lastUpdated = now;

          if (isApproved) {
            news.news?.validatedAt = now;
            news.news?.validatedObservation = reason;
            news.news?.validatedBy = validator;
            news.news?.validatedByName = validatorName;
          } else {
            if (isDeleted) {
              news.news?.excludedAt = now;
              news.news?.excludedBy = validator;
              news.news?.excludedObservation = reason;
            } else {
              news.news?.rejectedAt = now;
              news.news?.rejectedBy = validator;
              news.news?.rejectedObservation = reason;
            }
          }
          offlinePackageService.resignNewsPackage(news);
        }
      }
    } catch (e) {
      debugPrint("Erro ao atualizar revisão no Hive: $e");
      throw Exception("Erro ao atualizar revisão no Hive");
    }
  }

  //-----------------------------------------
  // Função de sincronização entre Hive e Firebase
  //-----------------------------------------

  Future<void> syncNewsHiveAndFirebase(UserModel user) async {
    /*bool isAdminOrEditor =
        user.role == UserRoles.admin || user.role == UserRoles.editor;*/

    try {
      List<NewsPackageModel> hivePackageNewsList =
          await getAllPackageNewsFromHive();

      for (NewsPackageModel hiveNews in hivePackageNewsList) {
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
              _savePackageNewsToFirebase(hiveNews);
            }
          } else {
            // Ambas existem: compara as datas de modificação para ver quem ganha
            DateTime? fbDate = fbNews.lastUpdated;
            DateTime? hiveDate = hiveNews.news?.lastUpdated;

            if (fbDate != null && hiveDate != null) {
              DateTime cleanFbDate = _trimDateTime(fbDate);
              DateTime cleanHiveDate = _trimDateTime(hiveDate);

              if (cleanFbDate.isAfter(cleanHiveDate)) {
                await saveNewsPackageInHive(fbNews);
              } else if (cleanHiveDate.isAfter(cleanFbDate)) {
                await _savePackageNewsToFirebase(hiveNews);
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

  /// Retorna uma lista ordenada de chaves públicas para um dado e-mail.
  /// A primeira posição [0] é a chave pública atual.
  /// As posições seguintes contêm as chaves antigas em ordem reversa (da mais recente para a mais antiga).
  Future<List<String>> getKeysListByEmail(String email) async {
    List<String> orderedKeys = [];

    try {
      // 1. Busca o modelo completo do autor usando a função do repositório
      // Substitua `keyRepository` pela instância correta do seu projeto, ou passe o modelo como parâmetro.
      PublicKeyModel? authorKeyModel =
          await getAuthorKeyModelFromPackage(email);

      if (authorKeyModel != null) {
        /*
        // Regra de Segurança Opcional: Se a chave foi revogada, retorna lista vazia para bloquear a leitura
        if (authorKeyModel.revocationInfo?.isRevoked == true) {
          debugPrint("Atenção: As chaves do e-mail $email foram revogadas.");
          return orderedKeys; // Retorna vazio
        }*/

        // 2. Adiciona a chave pública ativa no momento (a mais atual)
        if (authorKeyModel.publicKey != null &&
            authorKeyModel.publicKey!.isNotEmpty) {
          orderedKeys.add(authorKeyModel.publicKey!);
        }

        // 3. Adiciona o histórico de chaves antigas (oldPublicKeys) de forma invertida
        if (authorKeyModel.oldPublicKeys != null &&
            authorKeyModel.oldPublicKeys!.isNotEmpty) {
          // O comando .reversed do Dart inverte a ordem da lista automaticamente
          orderedKeys.addAll(authorKeyModel.oldPublicKeys!.reversed);
        }
      }
    } catch (e) {
      debugPrint("Erro ao processar lista de chaves para $email: $e");
    }

    return orderedKeys;
  }

  /// Busca um PublicKeyModel específico dentro de um PublicKeyPackage através do e-mail.
  /// Retorna o modelo se encontrado, ou null caso o e-mail não esteja no pacote.
  Future<PublicKeyModel?> getAuthorKeyModelFromPackage(String email) async {
    PublicKeyPackage? localKeyPackage = await getPublicKeyPackage();

    try {
      // Itera sobre a lista de chaves públicas do pacote
      for (var keyModel in localKeyPackage!.publicKeys) {
        // Verifica se o e-mail do modelo bate com o e-mail procurado
        if (keyModel.email == email) {
          return keyModel; // Retorna o modelo completo do autor encontrado
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar a chave do e-mail $email no pacote: $e");
    }

    // Retorna nulo se o laço terminar sem encontrar o e-mail
    return null;
  }
}
