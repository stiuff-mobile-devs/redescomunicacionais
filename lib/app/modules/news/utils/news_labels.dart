import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news/utils/categories.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_types.dart';

// Traduz para exibição os valores gravados nas matérias (categorias e tipos).
// Os dados continuam em português; só o texto mostrado na tela muda.
class NewsLabels {
  NewsLabels._();

  // Categoria gravada -> texto no idioma atual
  static String category(String raw) =>
      Categories.all.contains(raw) ? raw.tr : raw;

  // Tipo gravado ('Notícia', 'Opinião') -> texto no idioma atual
  static String type(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return NewsTypes.all.contains(raw) ? raw.tr : raw;
  }
}
