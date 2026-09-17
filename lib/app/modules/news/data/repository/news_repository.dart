import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/keys_package_model.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/news_package_model.dart';
import 'package:redescomunicacionais/app/modules/mesh/services/package_service.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/provider/news_provider.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';

class NewsRepository {
  NewsRepository();
  final NewsProvider newsProvider = NewsProvider();
  final OfflinePackageService _offlinePackageService = OfflinePackageService();

  Future<void> saveNewsToHive(NewsModel news) async {
    await newsProvider.saveNewsToHive([news]);
  }

  Future<void> syncNewsHiveAndFirebase(UserModel user) async {
    await newsProvider.syncNewsHiveAndFirebase(user);
  }

  Future<List<NewsModel>> getNewsFromHive({bool isPublic = false}) async {
    return newsProvider.getNewsFromHive(isPublic: isPublic);
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?>
      getPublicNewsPaginatedFromFirebase(
          QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument) async {
    return await newsProvider.getPublicNewsPaginatedFromFirebase(
        lastDocument: lastDocument);
  }

  Future<void> getOuthersNewsFromFirebase(UserModel user) async {
    await newsProvider.getOuthersNewsFromFirebase(user);
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

  Future<void> savePublicationTermsToFirebase({
    required String newsId,
    required Map<String, dynamic> terms,
  }) async {
    await newsProvider.savePublicationTermsToFirebase(
      newsId: newsId,
      terms: terms,
    );
  }

  Future<void> saveNewsToPackage(NewsModel news) async {
    await _offlinePackageService.createPackage(news);
  }

  Future<NewsPackageModel?> getPackageNews(String id) async {
    return await newsProvider.getPackageNews(id);
  }

  Future<List<NewsPackageModel>> getAllPackageNews() async {
    return await newsProvider.getAllPackageNews();
  }

  Future<void> saveNewsPackageInHive(NewsPackageModel package) async {
    return await newsProvider.saveNewsPackageInHive(package);
  }

  Future<PublicKeyPackage?> getPublicKeyPackage() async {
    return await newsProvider.getPublicKeyPackage();
  }

  Future<List<String>> getKeysListByEmail(String email) async {
    return await  newsProvider.getKeysListByEmail(email);
  }

  Future<void> savePublicKeyPackage(PublicKeyPackage package) async {
    return await newsProvider.savePublicKeyPackage(package);}
}
