import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/provider/news_provider.dart';

class NewsRepository {
  NewsRepository();
  final NewsProvider newsProvider = NewsProvider();

  Future<void> saveNewsToFirebase(NewsModel news) async {
    await newsProvider.saveNewsToFirebase(news);
  }

  Future<void> saveNewsToHive(NewsModel news) async {
    await newsProvider.saveNewsToHive(news);
  }

  Future<List<NewsModel>> getNewsFromHive() {
    return newsProvider.getNewsFromHive();
  }

  Future<List<NewsModel>> getNewsFromFirebase() {
    return newsProvider.getNewsFromFirebase();
  }

  Future<String> hideNews(
      String newsId, String status, String userEmail) async {
    return await newsProvider.hideNews(newsId, status, userEmail);
  }

  Future<String> updateNews(
      String newsId, Map<String, dynamic> updatedData) async {
    try {
      await newsProvider.updateNews(newsId, updatedData);
      return "success";
    } catch (e) {
      return "Erro ao atualizar notícia: $e";
    }
  }

  Future<void> reviewNews(String newsId, bool isApproved, String reason,
      String validator, String validatorName, String newsType) async {
    await newsProvider.reviewNews(
      newsId: newsId,
      isApproved: isApproved,
      reason: reason,
      validator: validator,
      validatorName: validatorName,
      newsType: newsType,
    );
  }

  Future<void> syncHiveAndFirebase() async {
    await newsProvider.syncHiveAndFirebase();
  }
}
