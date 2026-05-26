import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/web/translations/web_local_translations.dart';
import 'package:redescomunicacionais/app/utils/translations/languages/en_us_translation.dart';
import 'package:redescomunicacionais/app/utils/translations/languages/es_es_translation.dart';
import 'package:redescomunicacionais/app/utils/translations/languages/it_it_translation.dart';
import 'package:redescomunicacionais/app/utils/translations/languages/pt_br_translation.dart';

class AppTranslation extends Translations {
  static const Locale fallback = Locale('pt', 'BR');

  static const List<Locale> supportedLocales = [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
    Locale('it', 'IT'),
    Locale('es', 'ES'),
  ];

  static Locale normalizeLocale(Locale? locale) {
    if (locale == null) return fallback;

    final exactMatch = supportedLocales.where(
      (supported) =>
          supported.languageCode == locale.languageCode &&
          supported.countryCode == locale.countryCode,
    );

    if (exactMatch.isNotEmpty) {
      return exactMatch.first;
    }

    final languageMatch = supportedLocales.where(
      (supported) => supported.languageCode == locale.languageCode,
    );

    if (languageMatch.isNotEmpty) {
      return languageMatch.first;
    }

    return fallback;
  }

  @override
  Map<String, Map<String, String>> get keys {
    final Map<String, Map<String, String>> base = {
      'pt_BR': ptBrTranslation,
      'en_US': enUsTranslation,
      'it_IT': itItTranslation,
      'es_ES': esEsTranslation,
    };

    return {
      for (final localeKey in base.keys)
        localeKey: {
          ...base[localeKey]!,
          ...?webLocalTranslations[localeKey],
        },
    };
  }
}
