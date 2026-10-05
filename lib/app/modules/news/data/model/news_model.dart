import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
part 'news_model.g.dart';

@HiveType(typeId: 1)
class NewsModel {
  // ==========================================
  // 1. INFORMAÇÕES DO CONTEÚDO (Core Data)
  // ==========================================

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? subtitle;

  @HiveField(3)
  List<String> cities;

  @HiveField(4)
  List<String> categories;

  @HiveField(5)
  String body;

  @HiveField(6)
  List<String> urlImages;

  @HiveField(10)
  String type;

  @HiveField(21)
  String? videoUrl;

  // ==========================================
  // 2. STATUS E CONTROLE DE ESTADO
  // ==========================================

  @HiveField(11)
  String status;

  @HiveField(26)
  DateTime lastUpdated;

  @HiveField(31)
  Map<String, dynamic>? publicationTerms;

  // ==========================================
  // 3. CRIAÇÃO E AUTORIA
  // ==========================================

  @HiveField(7)
  String author;

  @HiveField(8)
  String createdBy;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(40)
  List<String>? collaborators;

  // ==========================================
  // 4. FLUXO DE VALIDAÇÃO / APROVAÇÃO
  // ==========================================

  @HiveField(12)
  String? validatedBy;

  @HiveField(30)
  String? validatedByName;

  @HiveField(13)
  DateTime? validatedAt;

  @HiveField(19)
  String? validatedObservation;

  // ==========================================
  // 5. FLUXO DE REJEIÇÃO
  // ==========================================

  @HiveField(23)
  String? rejectedBy;

  @HiveField(24)
  DateTime? rejectedAt;

  @HiveField(25)
  String? rejectedObservation;

  // ==========================================
  // 6. HISTÓRICO DE EDIÇÃO E EXCLUSÃO
  // ==========================================

  @HiveField(15)
  DateTime? editedAt;

  @HiveField(16)
  String? excludedBy;

  @HiveField(17)
  DateTime? excludedAt;

  @HiveField(20)
  String? excludedObservation;

  NewsModel({
    String? id,
    required this.title,
    this.subtitle,
    required this.body,
    required this.cities,
    required this.categories,
    required this.urlImages,
    this.videoUrl,
    required this.type,
    required this.status,
    required this.lastUpdated,
    required this.author,
    required this.createdBy,
    required this.createdAt,
    this.validatedBy,
    this.validatedByName,
    this.validatedAt,
    this.validatedObservation,
    this.rejectedBy,
    this.rejectedAt,
    this.rejectedObservation,
    this.editedAt,
    this.excludedBy,
    this.excludedAt,
    this.excludedObservation,
    this.publicationTerms,
    this.collaborators,
  }) : id = id ?? const Uuid().v4();

  // ==========================================
  // SERIALIZAÇÃO PARA O FIREBASE (Usa Timestamp)
  // ==========================================
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'body': body,
      'cities': cities,
      'categories': categories,
      'urlImages': urlImages,
      'videoUrl': videoUrl,
      'type': type,
      'status': status,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'author': author,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'validatedBy': validatedBy,
      'validatedByName': validatedByName,
      'validatedAt': validatedAt != null ? Timestamp.fromDate(validatedAt!) : null,
      'validatedObservation': validatedObservation,
      'rejectedBy': rejectedBy,
      'rejectedAt': rejectedAt != null ? Timestamp.fromDate(rejectedAt!) : null,
      'rejectedObservation': rejectedObservation,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'excludedBy': excludedBy,
      'excludedAt': excludedAt != null ? Timestamp.fromDate(excludedAt!) : null,
      'excludedObservation': excludedObservation,
      'publicationTerms': publicationTerms,
      'collaborators' : collaborators,
    };

    const requiredKeys = {
      'id', 'title', 'body', 'cities', 'categories', 'urlImages',
      'type', 'status', 'lastUpdated', 'author', 'createdBy', 'createdAt',
    };

    data.removeWhere((key, value) {
      if (requiredKeys.contains(key)) return false;
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;
      if (value is Iterable && value.isEmpty) return true;
      return false;
    });

    return data;
  }

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String?,
      body: map['body'] as String,
      cities: List<String>.from(map['cities'] ?? []),
      categories: List<String>.from(map['categories'] ?? []),
      urlImages: List<String>.from(map['urlImages'] ?? []),
      videoUrl: map['videoUrl'] as String?,
      type: map['type'] as String,
      status: map['status'] as String,
      
      lastUpdated: _parseDate(map['lastUpdated']) ?? DateTime.now(),
      author: map['author'] as String,
      createdBy: map['createdBy'] as String,
      createdAt: _parseDate(map['createdAt'])!, 

      validatedBy: map['validatedBy'] as String?,
      validatedByName: map['validatedByName'] as String?,
      validatedAt: _parseDate(map['validatedAt']),
      validatedObservation: map['validatedObservation'] as String?,
      rejectedBy: map['rejectedBy'] as String?,
      rejectedAt: _parseDate(map['rejectedAt']),
      rejectedObservation: map['rejectedObservation'] as String?,
      editedAt: _parseDate(map['editedAt']),
      excludedBy: map['excludedBy'] as String?,
      excludedAt: _parseDate(map['excludedAt']),
      excludedObservation: map['excludedObservation'] as String?,
      publicationTerms: map['publicationTerms'] != null
          ? Map<String, dynamic>.from(map['publicationTerms'])
          : null,
      collaborators : List<String>.from(map['collaborators'] ?? [])
    );
  }

  // Permite ler datas tanto do Firebase (Timestamp) quanto da Rede Mesh (String ISO)
  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value); // <-- Essencial para decodificar o JSON recebido via rádio
    }
    return null;
  }

  // ==========================================
  // SERIALIZAÇÃO PARA A REDE MESH (Usa String ISO-8601)
  // ==========================================
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'body': body,
      'cities': cities,
      'categories': categories,
      'urlImages': urlImages,
      'videoUrl': videoUrl,
      'type': type,
      'status': status,
      // Converte as datas diretamente para texto para não quebrar o jsonEncode
      'lastUpdated': lastUpdated.toIso8601String(),
      'author': author,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'validatedBy': validatedBy,
      'validatedByName': validatedByName,
      'validatedAt': validatedAt?.toIso8601String(),
      'validatedObservation': validatedObservation,
      'rejectedBy': rejectedBy,
      'rejectedAt': rejectedAt?.toIso8601String(),
      'rejectedObservation': rejectedObservation,
      'editedAt': editedAt?.toIso8601String(),
      'excludedBy': excludedBy,
      'excludedAt': excludedAt?.toIso8601String(),
      'excludedObservation': excludedObservation,
      'publicationTerms': publicationTerms,
      'collaborators': collaborators,
    };

    // Remove os campos nulos para economizar banda na transferência via Bluetooth
    data.removeWhere((key, value) => value == null);

    return data;
  }
}