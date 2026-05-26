import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';

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

      list.sort((a, b) {
        final dateA = a.lastUpdated ?? a.createdAt;
        final dateB = b.lastUpdated ?? b.createdAt;

        return dateB.compareTo(dateA);
      });

      return list;
    } catch (e) {
      throw Exception("Erro ao buscar no Hive: $e");
    }
  }

  Future<List<NewsModel>> _getNewsFromFirebase() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionPath)
          .orderBy('createdAt',
              descending:
                  true) // Ordena por createdAt do mais recente para o mais antigo
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NewsModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception("Erro ao buscar as matérias: $e");
    }
  }

  Future<void> hideNews(String newsId, String status, String userEmail) async {
    final now = DateTime.now();

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

  Future<void> syncNewsHiveAndFirebase() async {
    try {
      List<NewsModel> firebaseNewsList = await _getNewsFromFirebase();
      List<NewsModel> hiveNewsList = await getNewsFromHive();

      Map<String, NewsModel> firebaseMap = {
        for (var news in firebaseNewsList) news.id: news
      };
      Map<String, NewsModel> hiveMap = {
        for (var news in hiveNewsList) news.id: news
      };

      Set<String> allIds = {...firebaseMap.keys, ...hiveMap.keys};

      for (String id in allIds) {
        // Usando try-catch individual para não travar o loop inteiro se um ID der erro
        try {
          NewsModel? fbNews = firebaseMap[id];
          NewsModel? hiveNews = hiveMap[id];

          if (fbNews != null && hiveNews == null) {
            // Existe apenas no Firebase: baixar para o celular
            await saveNewsToHive(fbNews);
          } else if (fbNews == null && hiveNews != null) {
            // Existe apenas no celular: subir para a nuvem
            await _saveNewsToFirebase(hiveNews);
          } else if (fbNews != null && hiveNews != null) {
            // Existe nos dois: Verificar quem ganha

            final fbDate = fbNews.lastUpdated;
            final hiveDate = hiveNews.lastUpdated;

            if (fbDate != null && hiveDate != null) {
              if (fbDate.isAfter(hiveDate)) {
                // Firebase é mais novo -> Atualiza só o Hive
                await saveNewsToHive(fbNews);
              } else if (hiveDate.isAfter(fbDate)) {
                // Hive é mais novo -> Atualiza só o Firebase
                await _saveNewsToFirebase(hiveNews);
              }
              // Se forem iguais, não faz nada! Economiza processamento.
            } else if (fbDate != null) {
              // Só Firebase tem data -> Atualiza Hive
              await saveNewsToHive(fbNews);
            } else if (hiveDate != null) {
              // Só Hive tem data -> Atualiza Firebase
              await _saveNewsToFirebase(hiveNews);
            }
          }
        } catch (e) {
          debugPrint("Erro ao sincronizar a notícia ID $id: $e");
          // Continua para o próximo ID mesmo se este falhar
        }
      }
    } catch (e) {
      throw Exception("Erro fatal ao sincronizar Hive e Firebase: $e");
    }
  }
}
