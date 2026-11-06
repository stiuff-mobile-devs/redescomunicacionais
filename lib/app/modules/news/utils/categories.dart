import 'package:redescomunicacionais/app/utils/translations/locale_keys.dart';

// Categorias das matérias.
// O valor gravado na matéria (Hive, Firebase, mesh e assinatura) é sempre o
// texto em português; para exibir, use NewsLabels.category().
class Categories {
  static const List<String> all = [
    LocaleKeys.categoryPolitics,
    LocaleKeys.categorySecurity,
    LocaleKeys.categoryEducation,
    LocaleKeys.categoryHealth,
    LocaleKeys.categoryTransport,
    LocaleKeys.categoryEconomy,
    LocaleKeys.categoryJobs,
    LocaleKeys.categoryCulture,
    LocaleKeys.categoryTourism,
    LocaleKeys.categorySports,
    LocaleKeys.categoryEnvironment,
    LocaleKeys.categoryInfrastructure,
    LocaleKeys.categoryHousing,
    LocaleKeys.categoryTechnology,
    LocaleKeys.categoryCommunity,
  ];

  List<String> categories = all;
}
