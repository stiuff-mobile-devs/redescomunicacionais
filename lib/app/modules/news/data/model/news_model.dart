import 'package:cloud_firestore/cloud_firestore.dart';
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
  DateTime? lastUpdated;

  // ==========================================
  // 3. CRIAÇÃO E AUTORIA
  // ==========================================

  @HiveField(7)
  String author;

  @HiveField(8)
  String createdBy;

  @HiveField(9)
  DateTime createdAt;

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
    // --- Conteúdo Principal ---
    required this.id,
    required this.title,
    this.subtitle,
    required this.body,
    required this.cities,
    required this.categories,
    required this.urlImages,
    this.videoUrl,
    required this.type,

    // --- Status e Controle ---
    required this.status,
    this.lastUpdated,

    // --- Criação e Autoria ---
    required this.author,
    required this.createdBy,
    required this.createdAt,

    // --- Fluxo de Validação ---
    this.validatedBy,
    this.validatedByName,
    this.validatedAt,
    this.validatedObservation,

    // --- Fluxo de Rejeição ---
    this.rejectedBy,
    this.rejectedAt,
    this.rejectedObservation,

    // --- Histórico de Edição e Exclusão ---
    this.editedAt,
    this.excludedBy,
    this.excludedAt,
    this.excludedObservation,
  });

  Map<String, dynamic> toMap() {
    return {
      // --- Conteúdo ---
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'body': body,
      'cities': cities,
      'categories': categories,
      'urlImages': urlImages,
      'videoUrl': videoUrl,
      'type': type,

      // --- Status ---
      'status': status,
      // Converte DateTime? para Timestamp?
      'lastUpdated':
          lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,

      // --- Autoria ---
      'author': author,
      'createdBy': createdBy,
      // Converte DateTime para Timestamp (obrigatório)
      'createdAt': Timestamp.fromDate(createdAt),

      // --- Validação ---
      'validatedBy': validatedBy,
      'validatedByName': validatedByName,
      'validatedAt':
          validatedAt != null ? Timestamp.fromDate(validatedAt!) : null,
      'validatedObservation': validatedObservation,

      // --- Rejeição ---
      'rejectedBy': rejectedBy,
      'rejectedAt': rejectedAt != null ? Timestamp.fromDate(rejectedAt!) : null,
      'rejectedObservation': rejectedObservation,

      // --- Edição e Exclusão ---
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'excludedBy': excludedBy,
      'excludedAt': excludedAt != null ? Timestamp.fromDate(excludedAt!) : null,
      'excludedObservation': excludedObservation,
    };
  }

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      // ==========================================
      // 1. INFORMAÇÕES DO CONTEÚDO
      // ==========================================
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'],
      body: map['body'] ?? '',
      cities: List<String>.from(map['cities'] ?? []),
      categories: List<String>.from(map['categories'] ?? []),
      urlImages: List<String>.from(map['urlImages'] ?? []),
      videoUrl: map['videoUrl'],
      type: map['type'] ?? '',

      // ==========================================
      // 2. STATUS E CONTROLE DE ESTADO
      // ==========================================
      status: map['status'] ?? '',
      lastUpdated: _parseDate(map['lastUpdated']),

      // ==========================================
      // 3. CRIAÇÃO E AUTORIA
      // ==========================================
      author: map['author'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: _parseDate(map['createdAt']) ??
          DateTime.now(), // Fallback caso createdAt venha corrompido

      // ==========================================
      // 4. FLUXO DE VALIDAÇÃO
      // ==========================================
      validatedBy: map['validatedBy'],
      validatedByName: map['validatedByName'],
      validatedAt: _parseDate(map['validatedAt']),
      validatedObservation: map['validatedObservation'],

      // ==========================================
      // 5. FLUXO DE REJEIÇÃO
      // ==========================================
      rejectedBy: map['rejectedBy'],
      rejectedAt: _parseDate(map['rejectedAt']),
      rejectedObservation: map['rejectedObservation'],

      // ==========================================
      // 6. HISTÓRICO DE EDIÇÃO E EXCLUSÃO
      // ==========================================
      editedAt: _parseDate(map['editedAt']),
      excludedBy: map['excludedBy'],
      excludedAt: _parseDate(map['excludedAt']),
      excludedObservation: map['excludedObservation'],
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
