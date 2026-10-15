import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'public_key_package.g.dart';

@HiveType(typeId: 3)
class PublicKeyPackage extends HiveObject {
 
  @HiveField(4, defaultValue: <String, List<String>>{})
  final Map<String, List<String>> publicKeys;

  @HiveField(1)
  final String sender;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String signature;

  PublicKeyPackage({
    required this.publicKeys,
    required this.sender,
    required this.timestamp,
    required this.signature,
  });

  factory PublicKeyPackage.fromJson(Map<String, dynamic> json) {
    return PublicKeyPackage(
      publicKeys: _parsePublicKeys(json['publicKeys']),
      sender: json['sender'] as String? ?? '',
      timestamp: _parseDate(json['timestamp']) ?? DateTime.now(),
      signature: json['signature'] as String? ?? '',
    );
  }

  /// Chaves de um e-mail, da atual [0] para as mais antigas. Vazia se não houver.
  List<String> keysByEmail(String email) => publicKeys[email] ?? const [];

  // ==========================================
  // SERIALIZAÇÃO PARA A REDE MESH (Usa String ISO-8601)
  // ==========================================
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'publicKeys': publicKeys,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'signature': signature,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  // ==========================================
  // SERIALIZAÇÃO PARA O FIREBASE (Preserva DateTime nativo)
  // ==========================================
  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'publicKeys': publicKeys,
      'sender': sender,
      'timestamp': timestamp,
      'signature': signature,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  // Alias para retrocompatibilidade
  Map<String, dynamic> toMap() => toFirebase();

  static Map<String, List<String>> _parsePublicKeys(dynamic value) {
    if (value is! Map) return {};
    return value.map(
      (email, keys) => MapEntry(
        email as String,
        keys is List ? keys.map((k) => k.toString()).toList() : <String>[],
      ),
    );
  }

  // Interpretador Híbrido: Firestore, Dart e JSON/Mesh
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
