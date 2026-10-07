import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/mesh/model/public_key_model.dart';

part 'public_key_package.g.dart';

@HiveType(typeId: 3)
class PublicKeyPackage extends HiveObject {
  @HiveField(0)
  final List<PublicKeyModel> publicKeys;

  @HiveField(1)
  final String senderEmail;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String signature;

  PublicKeyPackage({
    required this.publicKeys,
    required this.senderEmail,
    required this.timestamp,
    required this.signature,
  });

  factory PublicKeyPackage.fromJson(Map<String, dynamic> json) {
    return PublicKeyPackage(
      publicKeys: (json['publicKeys'] as List<dynamic>?)
              ?.map((e) => PublicKeyModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      senderEmail: json['senderEmail'] as String? ?? '',
      timestamp: _parseDate(json['timestamp']) ?? DateTime.now(),
      signature: json['signature'] as String? ?? '',
    );
  }

  // ==========================================
  // SERIALIZAÇÃO PARA A REDE MESH (Usa String ISO-8601)
  // ==========================================
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'publicKeys': publicKeys.map((e) => e.toJson()).toList(),
      'senderEmail': senderEmail,
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
      'publicKeys': publicKeys.map((e) => e.toFirebase()).toList(),
      'senderEmail': senderEmail,
      'timestamp': timestamp,
      'signature': signature,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  // Alias para retrocompatibilidade
  Map<String, dynamic> toMap() => toFirebase();

  // Interpretador Híbrido: Firestore, Dart e JSON/Mesh
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}