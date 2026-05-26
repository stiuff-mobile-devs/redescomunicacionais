import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';

class NewsProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = "news";

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

  Future<List<NewsModel>> _getNewsFromFirebase(UserModel user) async {
    try {
      Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> docs = {};
      bool isAdminOrEditor =
          user.role == UserRoles.admin || user.role == UserRoles.editor;

      if (!isAdminOrEditor) {
        // 1. Usuário comum: Busca APENAS as públicas de forma direta e rápida
        QuerySnapshot<Map<String, dynamic>> publicSnapshot = await _firestore
            .collection(collectionPath)
            .where('status', whereIn: [NewsStates.publicado]).get();

        for (var doc in publicSnapshot.docs) {
          docs[doc.id] = doc;
        }
      } else {
        // 2. Admin/Editor: Dispara as 3 consultas necessárias em paralelo
        List<Future<QuerySnapshot<Map<String, dynamic>>>> futures = [
          // Públicas
          _firestore.collection(collectionPath).where('status', whereIn: [
            NewsStates.publicado,
          ]).get(),

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
          _firestore.collection(collectionPath).where('status', whereIn: [
            NewsStates.emAnalise,
          ]).get(),
        ];

        List<QuerySnapshot<Map<String, dynamic>>> snapshots =
            await Future.wait(futures);

        // Agrupa removendo duplicatas
        for (var snapshot in snapshots) {
          for (var doc in snapshot.docs) {
            docs[doc.id] = doc;
          }
        }
      }

      // 3. Mapeia o resultado final unificado para a lista de modelos
      return docs.values.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return NewsModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception("Erro ao buscar as matérias: $e");
    }
  }

  Future<void> saveNewsToHive(NewsModel news) async {
    try {
      // Verifiqua se a box já está aberta para evitar lentidão
      var box = Hive.isBoxOpen(collectionPath)
          ? Hive.box<NewsModel>(collectionPath)
          : await Hive.openBox<NewsModel>(collectionPath);

      //  salva ou atualiza se o ID já existir
      await box.put(news.id, news);
    } catch (e) {
      throw Exception("Erro ao salvar no Hive local: $e");
    }
  }

  Future<List<NewsModel>> getNewsFromHive() async {
    try {
      final box = Hive.isBoxOpen(collectionPath)
          ? Hive.box<NewsModel>(collectionPath)
          : await Hive.openBox<NewsModel>(collectionPath);

      List<NewsModel> list = box.values.toList().cast<NewsModel>();

      return list;
    } catch (e) {
      throw Exception("Erro ao buscar no Hive: $e");
    }
  }

  Future<void> _deleteNewsFromHive(String newsId) async {
    try {
      var box = await Hive.openBox<NewsModel>(collectionPath);

      // Verifica se a notícia realmente existe no Hive antes de deletar
      if (box.containsKey(newsId)) {
        await box.delete(newsId);
        debugPrint("Notícia ID $newsId deletada com sucesso do Hive.");
      } else {
        debugPrint("A notícia ID $newsId não foi encontrada no Hive.");
      }
    } catch (e) {
      debugPrint("Erro ao deletar a notícia do Hive: $e");
      throw Exception("Erro ao remover dados locais: $e");
    }
  }

  Future<void> hideNews(String newsId, String status, String userEmail) async {
    DateTime now = DateTime.now();

    try {
      if (Hive.isBoxOpen(collectionPath)) {
        var box = Hive.box<NewsModel>(collectionPath);
        var news = box.get(newsId);
        if (news != null) {
          news.status = status;
          news.excludedAt = now;
          news.excludedBy = userEmail;
          news.lastUpdated = now;
          await box.put(newsId, news);
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

  // 1. Receba o e-mail do usuário logado atual
  Future<void> syncNewsHiveAndFirebase(UserModel user) async {
    try {
      // Agora passamos o email para o Firebase trazer apenas o que é permitido
      List<NewsModel> firebaseNewsList = await _getNewsFromFirebase(user);
      List<NewsModel> hiveNewsList = await getNewsFromHive();

      Map<String, NewsModel> firebaseMap = {
        for (var news in firebaseNewsList) news.id: news
      };
      Map<String, NewsModel> hiveMap = {
        for (var news in hiveNewsList) news.id: news
      };

      Set<String> allIds = {...firebaseMap.keys, ...hiveMap.keys};

      for (String id in allIds) {
        try {
          NewsModel? fbNews = firebaseMap[id];
          NewsModel? hiveNews = hiveMap[id];

          if (fbNews != null && hiveNews == null) {
            // Existe apenas no Firebase: baixar para o celular
            await saveNewsToHive(fbNews);
          } else if (fbNews == null && hiveNews != null) {
            if (hiveNews.createdBy == user.email) {
              await _saveNewsToFirebase(hiveNews);
            } else {
              await _deleteNewsFromHive(id);
              debugPrint("Lixo antigo removido do Hive local: ID $id");
            }
          } else if (fbNews != null && hiveNews != null) {
            DateTime? fbDate = fbNews.lastUpdated;
            DateTime? hiveDate = hiveNews.lastUpdated;

            if (fbDate != null && hiveDate != null) {

              final fbClean = DateTime.fromMillisecondsSinceEpoch(
                  fbDate.millisecondsSinceEpoch);
              final hiveClean = DateTime.fromMillisecondsSinceEpoch(
                  hiveDate.millisecondsSinceEpoch);
              if (fbClean.isAfter(hiveClean)) {
                await saveNewsToHive(fbNews);
              } else if (hiveClean.isAfter(fbClean)) {
                await _saveNewsToFirebase(hiveNews);
              }
            } else if (fbDate != null) {
              await saveNewsToHive(fbNews);
            } else if (hiveDate != null) {
              await _saveNewsToFirebase(hiveNews);
            }
          }
        } catch (e) {
          debugPrint("Erro ao sincronizar a notícia ID $id: $e");
        }
      }
    } catch (e) {
      throw Exception("Erro fatal ao sincronizar Hive e Firebase: $e");
    }
  }
}
