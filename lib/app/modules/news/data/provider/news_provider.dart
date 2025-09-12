import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';

class NewsProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = "news";

  // Add news to Firebase
  Future<void> saveNewsToFirebase(NewsModel news) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(news.id)
          .set(news.toMap());
    } catch (e) {
      throw Exception("Erro ao salvar notícia no firebase: $e");
    }
  }

  // Save news to Hive (local storage)
  Future<void> saveNewsToHive(NewsModel news) async {
    try {
      var box = await Hive.openBox<NewsModel>(collectionPath);
      await box.put(news.id, news);
    } catch (e) {
      throw Exception("Erro ao salvar notícia no Hive: $e");
    }
  }

  // Get news from Hive (local storage)
  Future<List<NewsModel>> getNewsFromHive() async {
    try {
      var box = await Hive.openBox<NewsModel>(collectionPath);
      return box.values.toList();
    } catch (e) {
      throw Exception("Erro ao buscar notícias do Hive: $e");
    }
  }

  // Get all news from Firebase
  Future<List<NewsModel>> getNewsFromFirebase() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionPath).get();

      return querySnapshot.docs
          .map((doc) =>
              NewsModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Erro ao buscar notícias: $e");
    }
  }

  Future<String> hideNews(
      String newsId, String status, String userEmail) async {
    try {
      await _firestore.collection(collectionPath).doc(newsId).update({
        'status': status,
        'excluedAt': DateTime.now().toIso8601String(),
        'excluedBy': userEmail,
      });
      return "success";
    } catch (e) {
      return "Error hiding news status: $e";
    }
  }
}
