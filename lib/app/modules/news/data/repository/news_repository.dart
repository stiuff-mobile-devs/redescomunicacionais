import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/provider/news_provider.dart';

class NewsRepository {

final NewsProvider newsProvider;

NewsRepository(this.newsProvider);

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
Future<String> hideNews(String newsId, String status, String userEmail) async {
  return await newsProvider.hideNews(newsId, status, userEmail);
}
}