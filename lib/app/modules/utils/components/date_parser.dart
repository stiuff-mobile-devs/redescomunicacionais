import 'package:cloud_firestore/cloud_firestore.dart';

// Leitura e escrita de datas usadas pelos models (Firestore, Hive e mesh)
class DateParser {
  DateParser._();

  // Interpretador Híbrido: Firestore, Dart e JSON/Mesh
  static DateTime? parse(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // String ISO-8601 em UTC com milissegundos, igual ao toISOString() do JS
  static String toJsIso(DateTime date) {
    return DateTime.fromMillisecondsSinceEpoch(
      date.millisecondsSinceEpoch,
      isUtc: true,
    ).toIso8601String();
  }
}
