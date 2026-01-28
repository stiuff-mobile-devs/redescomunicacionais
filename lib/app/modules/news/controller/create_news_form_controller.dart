import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/services/image_base64_service.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';

class CreateNewsFormController extends GetxController {
  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  // Controllers
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  late QuillController _bodyController;
  final _videoUrlController = TextEditingController();

  // Getters para acessar os controllers
  TextEditingController get titleController => _titleController;
  TextEditingController get subtitleController => _subtitleController;
  QuillController get bodyController => _bodyController;
  TextEditingController get videoUrlController => _videoUrlController;

  // Observáveis
  final _selectedCategories = <String>[].obs;
  final _selectedCities = <String>[].obs;
  final _type = Rxn<String>();
  final _showCategoryError = false.obs;
  final _showCityError = false.obs;
  final _showTypeError = false.obs;

  // Getters para observáveis
  List<String> get selectedCategories => _selectedCategories;
  List<String> get selectedCities => _selectedCities;
  String? get type => _type.value;
  bool get showCategoryError => _showCategoryError.value;
  bool get showCityError => _showCityError.value;
  bool get showTypeError => _showTypeError.value;

  // Dependências
  final HomeController _homeController = Get.find<HomeController>();
  final NewsController _newsController = Get.find<NewsController>();
  final ImageBase64Service _imageController = Get.find<ImageBase64Service>();

  // Listas de dados
  final List<String> categories = [
    'Política',
    'Segurança',
    'Educação',
    'Saúde',
    'Transporte público e trânsito',
    'Economia',
    'Emprego e oportunidades',
    'Cultura',
    'Turismo e lazer',
    'Esportes',
    'Meio Ambiente',
    'Infraestrutura da cidade',
    'Habitação',
    'Tecnologia',
    'Ação comunitária'
  ];

  final List<String> cities = [
    'São Sebastião do Alto',
    'Macuco',
    'Rio das Flores',
    'Comendador Levy Gasparian',
    'Laje do Muriaé',
    'São José de Ubá',
  ];

  final List<String> types = [
    'Notícia',
    'Opinião',
  ];

  @override
  void onInit() {
    super.onInit();
    _bodyController = QuillController.basic();
  }

  @override
  void onClose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _bodyController.dispose();
    super.onClose();
  }

  // Métodos para manipular categorias
  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    _showCategoryError.value = false;
  }

  // Métodos para manipular cidades
  void toggleCity(String city) {
    if (_selectedCities.contains(city)) {
      _selectedCities.remove(city);
    } else {
      // permite apenas uma cidade selecionada por vez
      _selectedCities
        ..clear()
        ..add(city);
    }
    _showCityError.value = false;
  }

  // Métodos para manipular tipo
  void toggleType(String selectedType) {
    if (_type.value == selectedType) {
      _type.value = null;
    } else {
      _type.value = selectedType;
    }
    _showTypeError.value = false;
  }

  // Validação e publicação
  void validateAndPublish() {
    // Reset de erros
    _showCategoryError.value = _selectedCategories.isEmpty;
    _showCityError.value = _selectedCities.isEmpty;
    _showTypeError.value = _type.value == null;

    if (_formKey.currentState!.validate() &&
        _selectedCategories.isNotEmpty &&
        _selectedCities.isNotEmpty &&
        _type.value != null) {
      _publishNews();
    }
  }

  void _publishNews() {
    final String title = _titleController.text;
    final String subtitle = _subtitleController.text;
    final String body = _getBodyText();
    List<String> urlImages = [_imageController.base64String ?? ""];
    final String author = _homeController.user.name!;
    final String email = _homeController.user.email;
    final String createdAt = DateTime.now().toString();
    final String videoUrl = _videoUrlController.text;
    _newsController.addNews(
      title,
      subtitle,
      _selectedCities.toList(),
      _selectedCategories.toList(),
      body,
      urlImages,
      author,
      email,
      createdAt,
      _type.value ?? '',
      NewsStates.emAnalise,
      videoUrl,
    );

    // Limpar formulário
    _clearForm();

    // Voltar para a tela anterior
    Get.back();
  }

  void _clearForm() {
    _titleController.clear();
    _subtitleController.clear();
    _bodyController.clear();
    _selectedCategories.clear();
    _selectedCities.clear();
    _type.value = null;
    _showCategoryError.value = false;
    _showCityError.value = false;
    _showTypeError.value = false;
  }

  String _getBodyText() {
    return jsonEncode(_bodyController.document.toDelta().toJson());
  }

  // Getter para acessar o ImageController externamente
  ImageBase64Service get imageController => _imageController;
}
