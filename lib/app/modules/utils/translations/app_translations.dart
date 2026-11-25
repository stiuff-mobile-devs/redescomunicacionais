import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/languages/en_us_translation.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/languages/es_es_translation.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/languages/it_it_translation.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/languages/pt_br_translation.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

class AppTranslation extends Translations {
  static const Locale fallback = Locale('pt', 'BR');

  // Chave do GetStorage onde fica o idioma escolhido pelo usuário
  static const String _storageKey = 'app_locale';

  static const List<Locale> supportedLocales = [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
    Locale('it', 'IT'),
    Locale('es', 'ES'),
  ];

  // Nome de cada idioma no seletor (chave de tradução)
  static const Map<String, String> localeLabelKeys = {
    'pt_BR': LocaleKeys.languagePortugueseBrazil,
    'en_US': LocaleKeys.languageEnglishUs,
    'it_IT': LocaleKeys.languageItalian,
    'es_ES': LocaleKeys.languageSpanish,
  };

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

  // Idioma inicial: o escolhido pelo usuário ou, se não houver, o do aparelho
  static Locale initialLocale() {
    final String? saved = GetStorage().read<String>(_storageKey);
    if (saved != null) {
      final parts = saved.split('_');
      return normalizeLocale(
        Locale(parts.first, parts.length > 1 ? parts[1] : null),
      );
    }
    return normalizeLocale(Get.deviceLocale);
  }

  // Idioma em uso agora (sempre um dos suportados)
  static Locale get currentLocale => normalizeLocale(Get.locale);

  // Data curta no formato do idioma atual (ex.: 06/11/2026 em pt_BR e
  // 11/6/2026 em en_US)
  static String formatDate(DateTime date) =>
      DateFormat.yMd(currentLocale.toString()).format(date);

  // Troca o idioma do app e grava a escolha para as próximas aberturas
  static Future<void> changeLocale(Locale locale) async {
    final normalized = normalizeLocale(locale);
    await GetStorage().write(_storageKey, normalized.toString());
    await Get.updateLocale(normalized);
  }

  @override
  Map<String, Map<String, String>> get keys => {
        'pt_BR': ptBrTranslation,
        'en_US': enUsTranslation,
        'it_IT': itItTranslation,
        'es_ES': esEsTranslation,
      };
}
