import 'package:redescomunicacionais/app/utils/translations/locale_keys.dart';

// Tipos de matéria.
// O valor gravado na matéria é sempre o texto em português; para exibir,
// use NewsLabels.type().
class NewsTypes {
  static const String news = LocaleKeys.typeNews;
  static const String opinion = LocaleKeys.typeOpinion;

  static const List<String> all = [news, opinion];

  List<String> types = all;
}
