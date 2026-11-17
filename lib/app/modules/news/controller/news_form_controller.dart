import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_form_data.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/ui/publication_opinion_terms_dialog.dart';
import 'package:redescomunicacionais/app/modules/news/ui/publication_terms_dialog.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/data/repository/user_repository.dart';
import 'package:redescomunicacionais/app/modules/utils/components/friendly_exception.dart';
import 'package:redescomunicacionais/app/modules/utils/news/categories.dart';
import 'package:redescomunicacionais/app/modules/utils/news/cities_codes.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_states.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_types.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:redescomunicacionais/app/services/image_base64_service.dart';

// Formulário único de matéria: criar (sem argumentos) e editar
// (argumento {'newsId': id}). A regra de negócio (status, cópia de rascunho,
// assinatura) fica no NewsController; aqui só o estado do formulário.
class NewsFormController extends GetxController {
  final UserRepository userRepository = UserRepository();
  late final NewsController _newsController;
  late final ImageBase64Service _imageController;
  late QuillController _bodyController;

  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _videoUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  TextEditingController get titleController => _titleController;
  TextEditingController get subtitleController => _subtitleController;
  QuillController get bodyController => _bodyController;
  TextEditingController get videoUrlController => _videoUrlController;
  ImageBase64Service get imageController => _imageController;
  GlobalKey<FormState> get formKey => _formKey;

  List<String> get selectedCategories => _selectedCategories;
  List<String> get selectedCities => _selectedCities;
  String? get type => _type.value;

  List<String> get selectedCollaborators => _selectedCollaborators;
  final _selectedCollaborators = <String>[].obs;

  // Nomes sugeridos na lista de colaboradores (nunca nulos nem vazios)
  final RxList<String> availableEditors = <String>[].obs;
  List<UserModel> users = [];

  bool get showCategoryError => _showCategoryError.value;
  bool get showCityError => _showCityError.value;
  bool get showTypeError => _showTypeError.value;

  final _selectedCategories = <String>[].obs;
  final _selectedCities = <String>[].obs;
  final _type = Rxn<String>();

  final _showCategoryError = false.obs;
  final _showCityError = false.obs;
  final _showTypeError = false.obs;

  // Evita toque duplo enquanto salva/envia
  final RxBool isSaving = false.obs;

  // Modo edição: id e status da matéria aberta (null = criar)
  String? _editingId;
  String? _editingStatus;
  final RxBool isEditing = false.obs;
  final RxBool isLoadingNews = false.obs;

  final List<String> categories = Categories().categories;
  final List<String> cities = CitiesCodes().cities.values.toList();
  final List<String> types = NewsTypes().types;

  @override
  Future<void> onInit() async {
    super.onInit();
    _bodyController = QuillController.basic();
    _newsController = Get.find<NewsController>();
    _imageController = Get.find<ImageBase64Service>();
    _imageController.clear();

    final args = Get.arguments;
    final newsId = args is Map ? args['newsId'] : null;
    if (newsId is String && newsId.isNotEmpty) {
      await _loadNewsForEdit(newsId);
    }

    availableEditors.assignAll(await _loadCollaboratorNames());
  }

  @override
  void onClose() {
    _imageController.clear();
    _titleController.dispose();
    _subtitleController.dispose();
    _bodyController.dispose();
    _videoUrlController.dispose();
    super.onClose();
  }

  // Preenche o formulário com a matéria do Hive (só se o usuário puder editar)
  Future<void> _loadNewsForEdit(String newsId) async {
    isLoadingNews.value = true;
    try {
      final NewsModel? news = await _newsController.getNewsForEdit(newsId);
      if (news == null) {
        AppPopups.error(LocaleKeys.newsNotEditable.tr);
        Get.back();
        return;
      }

      _editingId = news.id;
      _editingStatus = news.status;
      isEditing.value = true;

      _titleController.text = news.title;
      _subtitleController.text = news.subtitle ?? '';
      _videoUrlController.text = news.videoUrl ?? '';
      _bodyController = _quillFromBody(news.body);
      _selectedCategories.assignAll(news.categories);
      _selectedCities.assignAll(news.cities);
      _type.value = news.type.isEmpty ? null : news.type;
      _selectedCollaborators.assignAll(news.collaborators ?? []);
      _imageController
          .setImage(news.urlImages.isNotEmpty ? news.urlImages.first : null);
    } finally {
      isLoadingNews.value = false;
    }
  }

  QuillController _quillFromBody(String body) {
    if (body.trim().isEmpty) return QuillController.basic();
    try {
      return QuillController(
        document: Document.fromJson(List<dynamic>.from(jsonDecode(body))),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      // Corpo antigo em texto simples
      final controller = QuillController.basic();
      controller.document.insert(0, body);
      return controller;
    }
  }

  // Nomes para a lista de colaboradores. Online, busca na nuvem e guarda só os
  // nomes no aparelho; offline (ou sem permissão), usa a última lista salva.
  // Sem nada salvo, a lista fica vazia e resta o campo de nome manual.
  static const String _collaboratorsCacheKey = 'collaborator_names';

  Future<List<String>> _loadCollaboratorNames() async {
    final storage = GetStorage();
    try {
      users = await userRepository.getAllUsersFromFirebase();
      final names = users
          .map((user) => user.name?.trim() ?? '')
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      await storage.write(_collaboratorsCacheKey, names);
      return names;
    } catch (e) {
      debugPrint('Lista de colaboradores indisponível, usando o cache: $e');
      final cached = storage.read<List<dynamic>>(_collaboratorsCacheKey);
      return cached?.whereType<String>().toList() ?? [];
    }
  }

  void toggleCollaborator(String name) {
    if (_selectedCollaborators.contains(name)) {
      _selectedCollaborators.remove(name);
    } else {
      _selectedCollaborators.add(name);
    }
  }

  void addManualCollaborator(String name) {
    String trimmedName = name.trim();
    if (trimmedName.isNotEmpty && !_selectedCollaborators.contains(trimmedName)) {
      _selectedCollaborators.add(trimmedName);
    }
  }

  void removeCollaborator(String name) {
    _selectedCollaborators.remove(name);
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    _showCategoryError.value = false;
  }

  void toggleCity(String city) {
    if (_selectedCities.contains(city)) {
      _selectedCities.remove(city);
    } else {
      _selectedCities
        ..clear()
        ..add(city);
    }
    _showCityError.value = false;
  }

  void toggleType(String selectedType) {
    if (_type.value == selectedType) {
      _type.value = null;
    } else {
      _type.value = selectedType;
    }
    _showTypeError.value = false;
  }

  NewsFormData _formData() {
    final String? image = _imageController.base64String;
    return NewsFormData(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      body: jsonEncode(_bodyController.document.toDelta().toJson()),
      cities: _selectedCities.toList(),
      categories: _selectedCategories.toList(),
      type: _type.value ?? '',
      urlImages: [image ?? ''],
      videoUrl: _videoUrlController.text.trim(),
      collaborators: _selectedCollaborators.toList(),
    );
  }

  // Rascunho: sem validação (pode estar incompleto) e sem termos
  Future<void> saveDraft() async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      final bool createdCopy =
          await _newsController.saveDraft(_formData(), editingId: _editingId);
      AppPopups.success(createdCopy
          ? LocaleKeys.draftCopySaved.tr
          : LocaleKeys.draftSavedSuccess.tr);
      Get.back();
    } catch (e) {
      debugPrint('Erro ao salvar rascunho: $e');
      AppPopups.error(_errorMessage(e, LocaleKeys.saveDraftError));
    } finally {
      isSaving.value = false;
    }
  }

  // Enviar para revisão: valida e pede os termos em todos os modos
  Future<void> submitForReview() async {
    if (isSaving.value) return;

    _showCategoryError.value = _selectedCategories.isEmpty;
    _showCityError.value = _selectedCities.isEmpty;
    _showTypeError.value = _type.value == null;

    final bool formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid ||
        _selectedCategories.isEmpty ||
        _selectedCities.isEmpty ||
        _type.value == null) {
      AppPopups.error(LocaleKeys.fillRequiredFields.tr);
      return;
    }

    final Map<String, dynamic>? terms = await AppPopups.custom<Map<String, dynamic>>(
      _type.value == NewsTypes.opinion
          ? const PublicationOpinionTermsDialog()
          : const PublicationTermsDialog(),
    );
    if (terms == null) return;

    isSaving.value = true;
    try {
      await _newsController.submitForReview(_formData(), editingId: _editingId);
      _newsController.notifySaved(isEditing.value
          ? LocaleKeys.newsUpdatedSuccess.tr
          : LocaleKeys.newsSentForReview.tr);
      Get.back();
    } catch (e) {
      debugPrint('Erro ao enviar matéria: $e');
      AppPopups.error(_errorMessage(e,
          isEditing.value ? LocaleKeys.newsUpdateError : LocaleKeys.publishNewsError));
    } finally {
      isSaving.value = false;
    }
  }

  String _errorMessage(Object error, String fallbackKey) {
    if (error is FriendlyException) return error.messageKey.tr;
    return fallbackKey.tr;
  }

  // Editando uma matéria já enviada? (salvar rascunho cria uma cópia)
  bool get isEditingSubmitted =>
      isEditing.value && _editingStatus != NewsStates.rascunho;
}
