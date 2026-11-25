import 'package:redescomunicacionais/app/modules/utils/components/date_parser.dart';
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

  // @HiveField(31) obsoleto (antigo publicationTerms, existe só no Firebase).
  // Não reutilizar esse índice.

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
    this.collaborators,
  }) : id = id ?? const Uuid().v4();

 
  Map<String, dynamic> toFirebase() {
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
      'lastUpdated': lastUpdated, // DateTime nativo suportado pelo Firestore
      'author': author,
      'createdBy': createdBy,
      'createdAt': createdAt, // DateTime nativo suportado pelo Firestore
      'validatedBy': validatedBy,
      'validatedByName': validatedByName,
      'validatedAt': validatedAt,
      'validatedObservation': validatedObservation,
      'rejectedBy': rejectedBy,
      'rejectedAt': rejectedAt,
      'rejectedObservation': rejectedObservation,
      'editedAt': editedAt,
      'excludedBy': excludedBy,
      'excludedAt': excludedAt,
      'excludedObservation': excludedObservation,
      'collaborators': collaborators,
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
      // Datas convertidas estritamente para String ISO-8601 (UTC em milissegundos, igual ao JS toISOString)
      'lastUpdated': DateParser.toJsIso(lastUpdated),
      'author': author,
      'createdBy': createdBy,
      'createdAt': DateParser.toJsIso(createdAt),
      'validatedBy': validatedBy,
      'validatedByName': validatedByName,
      'validatedAt': validatedAt != null ? DateParser.toJsIso(validatedAt!) : null,
      'validatedObservation': validatedObservation,
      'rejectedBy': rejectedBy,
      'rejectedAt': rejectedAt != null ? DateParser.toJsIso(rejectedAt!) : null,
      'rejectedObservation': rejectedObservation,
      'editedAt': editedAt != null ? DateParser.toJsIso(editedAt!) : null,
      'excludedBy': excludedBy,
      'excludedAt': excludedAt != null ? DateParser.toJsIso(excludedAt!) : null,
      'excludedObservation': excludedObservation,
      'collaborators': collaborators,
    };

    // Remove campos nulos para reduzir o tamanho dos pacotes na malha P2P
    data.removeWhere((key, value) => value == null);

    return data;
  }

  // Leitura tolerante (Firestore e mesh):
  // - campo obrigatório ausente ou com tipo errado → FormatException, e quem
  //   chama descarta só esta matéria (inventar um valor mudaria o texto assinado);
  // - campo opcional com tipo errado → null; listas mantêm só os itens de texto;
  // - campos a mais são ignorados (ex.: publicationTerms, que existe só no
  //   Firebase e pode trazer Timestamp, que o Hive não sabe gravar).
  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      id: _requiredString(map, 'id'),
      title: _requiredString(map, 'title'),
      subtitle: _optionalString(map, 'subtitle'),
      body: _requiredString(map, 'body'),
      cities: _stringList(map['cities']) ?? [],
      categories: _stringList(map['categories']) ?? [],
      urlImages: _stringList(map['urlImages']) ?? [],
      videoUrl: _optionalString(map, 'videoUrl'),
      type: _requiredString(map, 'type'),
      status: _requiredString(map, 'status'),
      lastUpdated: DateParser.parse(map['lastUpdated']) ?? DateTime.now(),
      author: _requiredString(map, 'author'),
      createdBy: _requiredString(map, 'createdBy'),
      createdAt: DateParser.parse(map['createdAt']) ?? DateTime.now(),
      validatedBy: _optionalString(map, 'validatedBy'),
      validatedByName: _optionalString(map, 'validatedByName'),
      validatedAt: DateParser.parse(map['validatedAt']),
      validatedObservation: _optionalString(map, 'validatedObservation'),
      rejectedBy: _optionalString(map, 'rejectedBy'),
      rejectedAt: DateParser.parse(map['rejectedAt']),
      rejectedObservation: _optionalString(map, 'rejectedObservation'),
      editedAt: DateParser.parse(map['editedAt']),
      excludedBy: _optionalString(map, 'excludedBy'),
      excludedAt: DateParser.parse(map['excludedAt']),
      excludedObservation: _optionalString(map, 'excludedObservation'),
      collaborators: _stringList(map['collaborators']),
    );
  }

  static String _requiredString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is String) return value;
    throw FormatException('NewsModel: campo obrigatório "$key" inválido '
        '(${value?.runtimeType ?? 'ausente'})');
  }

  static String? _optionalString(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is String ? value : null;
  }

  static List<String>? _stringList(dynamic value) {
    if (value is! List) return null;
    return value.whereType<String>().toList();
  }

  // Cópia independente, para alterar e assinar sem mexer no objeto guardado
  // no Hive (que é a mesma instância em memória). Não muda o toJson().
  NewsModel copy() {
    return NewsModel(
      id: id,
      title: title,
      subtitle: subtitle,
      body: body,
      cities: List<String>.from(cities),
      categories: List<String>.from(categories),
      urlImages: List<String>.from(urlImages),
      videoUrl: videoUrl,
      type: type,
      status: status,
      lastUpdated: lastUpdated,
      author: author,
      createdBy: createdBy,
      createdAt: createdAt,
      validatedBy: validatedBy,
      validatedByName: validatedByName,
      validatedAt: validatedAt,
      validatedObservation: validatedObservation,
      rejectedBy: rejectedBy,
      rejectedAt: rejectedAt,
      rejectedObservation: rejectedObservation,
      editedAt: editedAt,
      excludedBy: excludedBy,
      excludedAt: excludedAt,
      excludedObservation: excludedObservation,
      collaborators:
          collaborators != null ? List<String>.from(collaborators!) : null,
    );
  }
}