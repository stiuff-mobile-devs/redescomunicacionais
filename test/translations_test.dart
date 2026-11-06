import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:redescomunicacionais/app/utils/translations/app_translations.dart';

// Garante que os 4 idiomas estão completos e coerentes com o LocaleKeys.
void main() {
  final translations = AppTranslation().keys;
  final ptBr = translations['pt_BR']!;

  // Lê os valores declarados em LocaleKeys direto do código-fonte
  // (o Dart não tem reflexão para listar as constantes).
  List<String> readLocaleKeys() {
    final source = File('lib/app/utils/translations/locale_keys.dart')
        .readAsStringSync();
    final regex = RegExp(
      r"static const \w+\s*=\s*'((?:[^'\\]|\\.)*)';",
      multiLine: true,
    );
    return regex
        .allMatches(source)
        .map((m) => m.group(1)!.replaceAll(r"\'", "'").replaceAll(r'\n', '\n'))
        .toList();
  }

  Set<String> paramsOf(String text) =>
      RegExp(r'@(\w+)').allMatches(text).map((m) => m.group(1)!).toSet();

  test('LocaleKeys não tem valores repetidos', () {
    final keys = readLocaleKeys();
    final duplicates = <String>{};
    final seen = <String>{};
    for (final key in keys) {
      if (!seen.add(key)) duplicates.add(key);
    }
    expect(duplicates, isEmpty,
        reason: 'Duas constantes com o mesmo texto viram a mesma chave');
  });

  test('toda chave do LocaleKeys existe no pt_BR', () {
    final missing = readLocaleKeys().where((k) => !ptBr.containsKey(k));
    expect(missing, isEmpty);
  });

  test('o pt_BR não tem chaves fora do LocaleKeys', () {
    final declared = readLocaleKeys().toSet();
    final extra = ptBr.keys.where((k) => !declared.contains(k));
    expect(extra, isEmpty);
  });

  for (final entry in translations.entries) {
    final locale = entry.key;
    final map = entry.value;

    test('$locale tem exatamente as mesmas chaves do pt_BR', () {
      final missing = ptBr.keys.where((k) => !map.containsKey(k)).toList();
      final extra = map.keys.where((k) => !ptBr.containsKey(k)).toList();
      expect(missing, isEmpty, reason: 'Faltando em $locale');
      expect(extra, isEmpty, reason: 'Sobrando em $locale');
    });

    test('$locale não tem traduções vazias', () {
      final empty = map.entries
          .where((e) => e.value.trim().isEmpty)
          .map((e) => e.key)
          .toList();
      expect(empty, isEmpty);
    });

    test('$locale usa os mesmos @parâmetros da chave', () {
      final wrong = map.entries
          .where((e) =>
              !const SetEquality().equals(paramsOf(e.key), paramsOf(e.value)))
          .map((e) => '${e.key} -> ${e.value}')
          .toList();
      expect(wrong, isEmpty);
    });
  }
}

// Comparação simples de conjuntos (evita depender do package:collection)
class SetEquality {
  const SetEquality();

  bool equals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}
