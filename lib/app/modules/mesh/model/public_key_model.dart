import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'public_key_model.g.dart';

@HiveType(typeId: 4)
class PublicKeyModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? email;

  @HiveField(2)
  String? publicKey;

  @HiveField(3)
  List<String>? oldPublicKeys;

  @HiveField(4)
  List<String>? cities;

  @HiveField(5)
  DateTime? createdAt;

  @HiveField(6)
  DateTime? lastUpdated;

  @HiveField(7)
  RevocationInfo? revocationInfo;

  PublicKeyModel({
    this.id,
    this.email,
    this.publicKey,
    this.oldPublicKeys,
    this.cities,
    this.createdAt,
    this.lastUpdated,
    this.revocationInfo,
  });

  factory PublicKeyModel.fromJson(Map<String, dynamic> json) {
    return PublicKeyModel(
      id: json['id'] as String?,
      email: json['email'] as String?,
      publicKey: json['publicKey'] as String?,
      oldPublicKeys: (json['oldPublicKeys'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      cities:
          (json['cities'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      createdAt: _parseTimestamp(json['createdAt']),
      lastUpdated: _parseTimestamp(json['lastUpdated']),
      revocationInfo: json['revocationInfo'] != null 
          ? RevocationInfo.fromJson(Map<String, dynamic>.from(json['revocationInfo'])) 
          : null,
    );
  }

  // ==========================================
  // SERIALIZAÇÃO PARA A REDE MESH (Usa String ISO-8601)
  // ==========================================
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'email': email,
      'publicKey': publicKey,
      'oldPublicKeys': oldPublicKeys,
      'cities': cities,
      // Converte datas nativas para texto ISO-8601 para segurança no jsonEncode
      'createdAt': createdAt?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'revocationInfo': revocationInfo?.toJson(),
    };

    // Remove campos nulos para economizar largura de banda na rede Mesh
    data.removeWhere((key, value) => value == null);

    return data;
  }

  // ==========================================
  // SERIALIZAÇÃO PARA O FIREBASE (Preserva DateTime nativo)
  // ==========================================
  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'id': id,
      'email': email,
      'publicKey': publicKey,
      'oldPublicKeys': oldPublicKeys,
      'cities': cities,
      // Mantém DateTime nativo para persistência direta no Firestore
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
      'revocationInfo': revocationInfo?.toFirebase(),
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  PublicKeyModel copyWith({
    String? id,
    String? email,
    String? publicKey,
    List<String>? oldPublicKeys,
    List<String>? cities,
    DateTime? createdAt,
    DateTime? lastUpdated,
    RevocationInfo? revocationInfo,
  }) {
    return PublicKeyModel(
      id: id ?? this.id,
      email: email ?? this.email,
      publicKey: publicKey ?? this.publicKey,
      oldPublicKeys: oldPublicKeys ?? this.oldPublicKeys,
      cities: cities ?? this.cities,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      revocationInfo: revocationInfo ?? this.revocationInfo,
    );
  }

  // Interpretador Híbrido: Firestore, Dart e JSON/Mesh
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

@HiveType(typeId: 12)
class RevocationInfo extends HiveObject {
  @HiveField(0)
  bool? isRevoked;

  @HiveField(1)
  DateTime? revokedAt;

  @HiveField(2)
  String? revokedBy;

  @HiveField(3)
  String? revocationReason;

  RevocationInfo({
    this.isRevoked,
    this.revokedAt,
    this.revokedBy,
    this.revocationReason,
  });

  factory RevocationInfo.fromJson(Map<String, dynamic> json) {
    return RevocationInfo(
      isRevoked: json['isRevoked'] as bool? ?? false,
      revokedAt: _parseTimestamp(json['revokedAt']),
      revokedBy: json['revokedBy'] as String?,
      revocationReason: json['revocationReason'] as String?,
    );
  }

  // ==========================================
  // SERIALIZAÇÃO PARA A REDE MESH (Usa String ISO-8601)
  // ==========================================
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'isRevoked': isRevoked,
      'revokedAt': revokedAt?.toIso8601String(),
      'revokedBy': revokedBy,
      'revocationReason': revocationReason,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  // ==========================================
  // SERIALIZAÇÃO PARA O FIREBASE (Preserva DateTime nativo)
  // ==========================================
  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'isRevoked': isRevoked,
      'revokedAt': revokedAt,
      'revokedBy': revokedBy,
      'revocationReason': revocationReason,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }

  RevocationInfo copyWith({
    bool? isRevoked,
    DateTime? revokedAt,
    String? revokedBy,
    String? revocationReason,
  }) {
    return RevocationInfo(
      isRevoked: isRevoked ?? this.isRevoked,
      revokedAt: revokedAt ?? this.revokedAt,
      revokedBy: revokedBy ?? this.revokedBy,
      revocationReason: revocationReason ?? this.revocationReason,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value; 
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}