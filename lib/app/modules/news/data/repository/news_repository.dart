import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/provider/news_provider.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';

class NewsRepository {
  NewsRepository();
  final NewsProvider newsProvider = NewsProvider();

  Future<void> saveNewsToHive(NewsModel news) async {
    await newsProvider.saveNewsToHive(news);
  }

  Future<void> syncNewsHiveAndFirebase(UserModel user) async {
    await newsProvider.syncNewsHiveAndFirebase(user);
  }

  Future<List<NewsModel>> getNewsFromHive() {
    return newsProvider.getNewsFromHive();
  }

  Future<void> hideNews(String newsId, String status, String userEmail) async {
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
}
