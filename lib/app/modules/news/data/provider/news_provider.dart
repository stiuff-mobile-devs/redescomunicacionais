import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/news_package_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';

class NewsProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = "news";

  //-----------------------------------------
  // Funções de manipulação Online (Firebase)
  //-----------------------------------------

  Future<void> _saveNewsToFirebase(NewsModel news) async {
    try {
      await _firestore.collection(collectionPath).doc(news.id).set(
            news.toMap(),
            SetOptions(merge: true),
          );
    } on FirebaseException catch (e) {
      throw Exception("Erro no Firebase (${e.code}): ${e.message}");
    } catch (e) {
      throw Exception("Erro desconhecido ao salvar: $e");
    }
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getPublicNewsPaginatedFromFirebase({
    QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument,
  }) async {
    try {
      QueryDocumentSnapshot<Map<String, dynamic>>? nextLastDocument;

      Query<Map<String, dynamic>> query = _firestore
          .collection(collectionPath)
          .where('status', whereIn: [NewsStates.publicado])
          .orderBy('createdAt', descending: true)
          .limit(10);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        nextLastDocument = snapshot.docs.last;
      }

      List<NewsModel> newsList = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return NewsModel.fromMap(data);
      }).toList();

      await saveNewsToHive(newsList);

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
            .where('status', whereIn: [
              NewsStates.rascunho,
              NewsStates.rejeitado,
              NewsStates.deletado,
            ])
            .where('createdBy', isEqualTo: user.email)
            .get(),

        // Todas as matérias que aguardam análise no sistema
        _firestore
            .collection(collectionPath)
            .where('status', whereIn: [NewsStates.emAnalise]).get(),
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
      List<NewsModel> othersNewsList = docs.values.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return NewsModel.fromMap(data);
      }).toList();

      await saveNewsToHive(othersNewsList);
    } catch (e) {
      throw Exception("Erro ao buscar matérias de administração: $e");
    }
  }

  Future<void> savePublicationTermsToFirebase({
    required String newsId,
    required Map<String, dynamic> terms,
  }) async {
    await _firestore
        .collection(collectionPath)
        .doc(newsId)
        .collection('publication_terms')
        .add({
      ...terms,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  Future<NewsModel?> _getNewsByIdFromFirebase(String id) async {
    var doc = await _firestore.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return NewsModel.fromMap(data);
  }

  Future<void> _saveNewsToApi(NewsModel news) async{
    try {
      NewsPackageModel? package = await getPackageNews(news.id);

      if (package != null) {
        
        Map<String, dynamic> packageMap = {
          'id': package.id,
          'email': package.email,
          'signature': package.signature,
          'isUploaded': package.isUploaded,
          'lastUpdated': package.lastUpdated?.toIso8601String(), 
        };
      //TODO: Enviar package e news para API
      } 
    } catch (e) {
      debugPrint("Ocorreu um erro ao buscar os dados: $e");
    }
  }
  
  Future<NewsPackageModel? > getPackageNews(String id) async{
    try {
       var box = Hive.isBoxOpen('news_packages')
          ? Hive.box<NewsPackageModel>('news_packages')
          : await Hive.openBox<NewsPackageModel>('news_packages');

      return box.get(id);
    } catch (e) {
      throw Exception("Erro ao buscar pacote de notícias: $e");
    }
  }

  //-----------------------------------------
  // Funções de manipulação local (Hive)
  //-----------------------------------------

  Future<List<NewsPackageModel>> getAllPackageNews() async {
    try {
      var box = Hive.isBoxOpen('news_packages')
          ? Hive.box<NewsPackageModel>('news_packages')
          : await Hive.openBox<NewsPackageModel>('news_packages');

      // Pega todos os valores da caixa e transforma em uma lista
      return box.values.toList();
    } catch (e) {
      throw Exception("Erro ao buscar todos os pacotes: $e");
    }
  }
  
  Future<void> saveNewsToHive(List<NewsModel> newsList) async {
  if (newsList.isEmpty) return;

  try {
    var box = Hive.isBoxOpen(collectionPath)
        ? Hive.box<NewsModel>(collectionPath)
        : await Hive.openBox<NewsModel>(collectionPath);

    final Map<String, NewsModel> newsMap = {
      for (var news in newsList) news.id: news
    };

    await box.putAll(newsMap);
    
  } catch (e) {
    throw Exception("Erro ao salvar dados no Hive local: $e");
  }
}

  Future<List<NewsModel>> getNewsFromHive({required bool isPublic}) async {
  try {
    final box = Hive.isBoxOpen(collectionPath)
        ? Hive.box<NewsModel>(collectionPath)
        : await Hive.openBox<NewsModel>(collectionPath);

    List<NewsModel> allList = box.values.toList().cast<NewsModel>();

    return allList.where((news) {
      if (isPublic) {
        return news.status == NewsStates.publicado;
      } else {
        return news.status == NewsStates.rascunho ||
               news.status == NewsStates.rejeitado ||
               news.status == NewsStates.deletado ||
               news.status == NewsStates.emAnalise;
      }
    }).toList();

  } catch (e) {
    final tipo = isPublic ? "públicas" : "internas";
    throw Exception("Erro ao buscar notícias $tipo no Hive: $e");
  }
}

  Future<void> hideNews(String newsId, String status, String userEmail) async {
    DateTime now = DateTime.now();

    try {
      
        final box = Hive.isBoxOpen(collectionPath)
        ? Hive.box<NewsModel>(collectionPath)
        : await Hive.openBox<NewsModel>(collectionPath);

        var news = box.get(newsId);

        if (news != null) {
          news.status = status;
          news.excludedAt = now;
          news.excludedBy = userEmail;
          news.lastUpdated = now;
          await box.put(newsId, news);
        }
      
    } catch (e) {
      debugPrint("Erro crítico ao atualizar Hive local: $e");
      throw Exception("Falha ao ocultar notícia.");
    }
  }

  Future<void> updateNews(
      String newsId, Map<String, dynamic> updatedData) async {
    try {
      final box = Hive.isBoxOpen(collectionPath)
          ? Hive.box<NewsModel>(collectionPath)
          : await Hive.openBox<NewsModel>(collectionPath);

      final existingNews = box.get(newsId);
      if (existingNews == null) {
        throw Exception('Notícia não encontrada no Hive local.');
      }

      final mergedData = existingNews.toMap()..addAll(updatedData);
      mergedData['id'] = newsId;

      final updatedNews = NewsModel.fromMap(mergedData);
      await box.put(newsId, updatedNews);
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
      if (Hive.isBoxOpen(collectionPath)) {
        var box = Hive.box<NewsModel>(collectionPath);
        var news = box.get(newsId);

        if (news != null) {
          // Atualizamos o objeto local com as mesmas informações
          news.status = updates['status'];
          news.type = updates['type'];
          news.lastUpdated = now;

          if (isApproved) {
            news.validatedAt = now;
            news.validatedObservation = reason;
            news.validatedBy = validator;
            news.validatedByName = validatorName;
          } else {
            if (isDeleted) {
              news.excludedAt = now;
              news.excludedBy = validator;
              news.excludedObservation = reason;
            } else {
              news.rejectedAt = now;
              news.rejectedBy = validator;
              news.rejectedObservation = reason;
            }
          }
          await box.put(newsId, news);
        }
      }
    } catch (e) {
      debugPrint("Erro ao atualizar revisão no Hive: $e");
      throw Exception("Erro ao atualizar revisão no Hive");
    }
  }

  Future<void> _deleteNewsFromHive(String newsId) async {
    try {
      final box = Hive.isBoxOpen(collectionPath)
        ? Hive.box<NewsModel>(collectionPath)
        : await Hive.openBox<NewsModel>(collectionPath);

      // Verifica se a notícia realmente existe no Hive antes de deletar
      if (box.containsKey(newsId)) {
        await box.delete(newsId);
      } 
    } catch (e) {
      throw Exception("Erro ao remover dados locais: $e");
    }
  }
 
  //-----------------------------------------
  // Função de sincronização entre Hive e Firebase
  //-----------------------------------------

  Future<void> syncNewsHiveAndFirebase(UserModel user) async {
    bool isAdminOrEditor =
        user.role == UserRoles.admin || user.role == UserRoles.editor;

    if (!isAdminOrEditor) {
      debugPrint("Usuário comum: Sincronização em segundo plano pulada.");
      return;
    }

    try {
      List<NewsModel> hiveNewsList = await getNewsFromHive(isPublic: false);
      hiveNewsList.addAll(await getNewsFromHive(isPublic: true));

      for (var hiveNews in hiveNewsList) {
        try {
          NewsModel? fbNews = await _getNewsByIdFromFirebase(hiveNews.id);

          if (fbNews == null) {
            // Se não existe no Firebase mas o autor criou localmente offline, envia pro servidor
            if (hiveNews.createdBy == user.email) {
              await _saveNewsToFirebase(hiveNews);
            } else {
              // Se sumiu do Firebase, remove do Hive local
              await _deleteNewsFromHive(hiveNews.id);
            }
          } else {
            if (hiveNews.createdBy != user.email &&
                (hiveNews.status == NewsStates.rascunho ||
                    hiveNews.status == NewsStates.rejeitado ||
                    hiveNews.status == NewsStates.deletado)) {
              // Se a notícia foi criada por outro usuário e está em rascunho, rejeitada ou deletada, remove do Hive local
              await _deleteNewsFromHive(hiveNews.id);
              continue; // Pula para a próxima iteração
            }
            // Ambas existem: compara as datas de modificação para ver quem ganha
            DateTime? fbDate = fbNews.lastUpdated;
            DateTime? hiveDate = hiveNews.lastUpdated;

            if (fbDate != null && hiveDate != null) {
              DateTime cleanFbDate = _trimDateTime(fbDate);
              DateTime cleanHiveDate = _trimDateTime(hiveDate);

              if (cleanFbDate.isAfter(cleanHiveDate)) {
                await saveNewsToHive([fbNews]);
              } else if (cleanHiveDate.isAfter(cleanFbDate)) {
                await _saveNewsToFirebase(hiveNews);
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
}
