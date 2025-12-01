import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';

class NewsProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = "news";

  Future<void> saveNewsToFirebase(NewsModel news) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(news.id)
          .set(news.toMap());
    } catch (e) {
      throw Exception("Erro ao salvar a matéria no firebase: $e");
    }
  }

  Future<void> saveNewsToHive(NewsModel news) async {
    try {
      var box = await Hive.openBox<NewsModel>(collectionPath);
      await box.put(news.id, news);
    } catch (e) {
      throw Exception("Erro ao salvar a matéria no Hive: $e");
    }
  }

  Future<List<NewsModel>> getNewsFromHive() async {
    try {
      var box = await Hive.openBox<NewsModel>(collectionPath);
      return box.values.toList();
    } catch (e) {
      throw Exception("Erro ao buscar as matérias do Hive: $e");
    }
  }

  Future<List<NewsModel>> getNewsFromFirebase() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionPath).get();

      return querySnapshot.docs
          .map((doc) =>
              NewsModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Erro ao buscar as matérias: $e");
    }
  }

  Future<String> hideNews(
      String newsId, String status, String userEmail) async {
    try {
      // Atualiza no Firestore
      await _firestore.collection(collectionPath).doc(newsId).update({
        'status': status,
        'excluedAt': DateTime.now().toIso8601String(),
        'excluedBy': userEmail,
      });

      // Atualiza no Hive (se existir, atualiza; se não, cria um registro mínimo)
      try {
        var box = await Hive.openBox<NewsModel>(collectionPath);
        final existing = box.get(newsId);

        // Monta o mapa de dados a ser salvo
        Map<String, dynamic> updatedMap =
            existing != null ? existing.toMap() : <String, dynamic>{};

        updatedMap['status'] = status;
        updatedMap['excluedAt'] = DateTime.now().toIso8601String();
        updatedMap['excluedBy'] = userEmail;

        await box.put(newsId, NewsModel.fromMap(newsId, updatedMap));
      } catch (e) {
        return "Error hiding news in Hive: $e";
      }

      return "success";
    } catch (e) {
      return "Error hiding news status: $e";
    }
  }

  Future<void> updateNews(
      String newsId, Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance
          .collection('news')
          .doc(newsId)
          .update(updatedData);
    } catch (e) {
      throw Exception("Erro ao atualizar notícia no Firebase: $e");
    }
  }

  reviewNews(String newsId, bool isApproved, String reason, String validator,
      String validatorName) async {
    try {
      await _firestore.collection(collectionPath).doc(newsId).update({
        'status': isApproved ? NewsStates.publicado : NewsStates.emAnalise,
        'validatedAt': DateTime.now().toIso8601String(),
        'validatedObservation': reason,
        'validatedBy': validator,
        'validatedByName': validatorName,
      });
    } catch (e) {
      throw Exception("Erro ao revisar notícia no Firebase: $e");
    }
  }
}
