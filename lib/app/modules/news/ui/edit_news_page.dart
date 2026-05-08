import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:redescomunicacionais/app/services/image_base64_service.dart';
import 'package:redescomunicacionais/app/modules/news/controller/update_news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';
import 'package:redescomunicacionais/app/utils/components/popups.dart';
import 'package:redescomunicacionais/app/utils/components/markdown_editor.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/utils/widgets/blinking_loading_icon.dart';

class EditNewsPage extends StatefulWidget {
  const EditNewsPage({super.key});

  @override
  State<EditNewsPage> createState() => _EditNewsPageState();
}

class _EditNewsPageState extends State<EditNewsPage> {
  final _formKey = GlobalKey<FormState>();
  final UpdateNewsController _updateNewsController =
      Get.put(UpdateNewsController());
  final ImageBase64Service _imageController = Get.put(ImageBase64Service());

  // Controllers para os campos
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late QuillController _bodyController;

  // Dados da notícia
  late String newsId;
  late String originalImageUrl;

  // Estado das seleções
  final RxList<String> selectedCategories = <String>[].obs;
  final RxList<String> selectedCities = <String>[].obs;
  final RxString selectedType = ''.obs;

  // Estado dos erros
  final RxBool showCategoryError = false.obs;
  final RxBool showCityError = false.obs;
  final RxBool showTypeError = false.obs;

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
  void initState() {
    super.initState();
    _loadNewsData();
  }

  void _loadNewsData() {
    // Recebe os dados via Get.arguments
    final args = Get.arguments as Map<String, dynamic>;

    newsId = args['newsId'] ?? '';
    originalImageUrl = args['imgurl'] ?? '';

    // Inicializa controllers com dados existentes
    _titleController = TextEditingController(text: args['titulo'] ?? '');
    _subtitleController = TextEditingController(text: args['subtitulo'] ?? '');

    // Inicializa QuillController com conteúdo existente
    _bodyController = QuillController.basic();
    if (args['corpo'] != null && args['corpo'].isNotEmpty) {
      try {
        // Se o corpo for JSON (Delta), carrega como documento
        final deltaJson = jsonDecode(args['corpo']);
        final document = Document.fromJson(deltaJson);
        _bodyController = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Se não for JSON, insere como texto simples
        _bodyController.document.insert(0, args['corpo']);
      }
    }

    // Carrega listas
    selectedCities.value = List<String>.from(args['cidade'] is String
        ? args['cidade'].split(', ')
        : args['cidade'] ?? []);
    selectedCategories.value = List<String>.from(args['categoria'] is String
        ? args['categoria'].split(', ')
        : args['categoria'] ?? []);
    selectedType.value = args['type'] ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('edit_news'.tr),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildSubtitleField(),
                  const SizedBox(height: 16),
                  _buildCategorySelection(),
                  const SizedBox(height: 16),
                  _buildCitySelection(),
                  const SizedBox(height: 16),
                  _buildTypeSelection(),
                  const SizedBox(height: 16),
                  _buildMarkdownEditor(),
                  const SizedBox(height: 16),
                  _buildImagePicker(),
                  const SizedBox(height: 16),
                  _buildImageInfo(),
                  _buildImagePreview(),
                  const SizedBox(height: 16),
                  _buildImageMessage(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'title'.tr,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'title_required'.tr;
        }
        return null;
      },
    );
  }

  Widget _buildSubtitleField() {
    return TextFormField(
      controller: _subtitleController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'subtitle_optional'.tr,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExpansionTile(
                title: Text(
                  'select_categories'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return CheckboxListTile(
                          title: Text(
                            category,
                            style: const TextStyle(color: Colors.white),
                          ),
                          value: selectedCategories.contains(category),
                          onChanged: (bool? isChecked) {
                            toggleCategory(category);
                          },
                          activeColor: Colors.blue,
                          side: const BorderSide(color: Colors.white, width: 2),
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (showCategoryError.value)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'select_at_least_one_category'.tr,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ));
  }

  Widget _buildCitySelection() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExpansionTile(
                title: Text(
                  'select_city'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return CheckboxListTile(
                          title: Text(
                            city,
                            style: const TextStyle(color: Colors.white),
                          ),
                          value: selectedCities.contains(city),
                          onChanged: (bool? isChecked) {
                            toggleCity(city);
                          },
                          activeColor: Colors.blue,
                          side: const BorderSide(color: Colors.white, width: 2),
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (showCityError.value)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'select_at_least_one_city'.tr,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ));
  }

  Widget _buildTypeSelection() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExpansionTile(
                title: Text(
                  'select_type'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                children: [
                  Column(
                    children: types.map((type) {
                      return CheckboxListTile(
                        title: Text(
                          type,
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: selectedType.value == type,
                        onChanged: (bool? isChecked) {
                          toggleType(type);
                        },
                        activeColor: Colors.blue,
                        side: const BorderSide(color: Colors.white, width: 2),
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            if (showTypeError.value)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'select_at_least_one_type'.tr,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ));
  }

  Widget _buildMarkdownEditor() {
    return SizedBox(
      height: 300,
      child: MarkdownEditor(controller: _bodyController),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _imageController.pickImage(),
        icon: const Icon(Icons.image),
        label: Text(
          'change_image'.tr,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildImageInfo() {
    return Text(
      'image_requirements'.tr,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Obx(() {
        // Se foi selecionada nova imagem
        if (_imageController.base64String != null) {
          return Column(
            children: [
              Image.memory(
                base64Decode(_imageController.base64String!),
                height: 150,
              ),
            ],
          );
        }
        // Senão, mostra imagem original
        else if (originalImageUrl.isNotEmpty) {
          try {
            return Column(
              children: [
                Image.memory(
                  base64Decode(originalImageUrl),
                  height: 150,
                ),
              ],
            );
          } catch (e) {
            return const SizedBox.shrink();
          }
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildImageMessage() {
    return Obx(() => Text(
          _imageController.message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
          ),
        ));
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final isLoading = _updateNewsController.isLoading.value;

      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : () => _validateAndUpdate(true),
              icon: const Icon(Icons.save_outlined, color: Colors.white),
              label: Text(
                'save_draft_news'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Colors.white70, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x663B82F6),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : () => _validateAndUpdate(false),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor:
                      isLoading ? Colors.grey : const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isLoading
                    ? const BlinkingLoadingIcon(
                        size: 22,
                        color: Colors.white,
                      )
                    : const Icon(Icons.update, color: Colors.white),
                label: Text(
                  'update_news'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // Métodos de toggle
  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    showCategoryError.value = false;
  }

  void toggleCity(String city) {
    if (selectedCities.contains(city)) {
      selectedCities.remove(city);
    } else {
      selectedCities.add(city);
    }
    showCityError.value = false;
  }

  void toggleType(String type) {
    selectedType.value = selectedType.value == type ? '' : type;
    showTypeError.value = false;
  }

  // Validação e atualização
  void _validateAndUpdate(bool draft) async {
    // Reset erros
    showCategoryError.value = false;
    showCityError.value = false;
    showTypeError.value = false;

    if (draft) {
      await _submitUpdate(NewsStates.rascunho);
      return;
    }

    // Validação do formulário
    bool isFormValid = _formKey.currentState?.validate() ?? false;

    // Validação das seleções
    if (selectedCategories.isEmpty) {
      showCategoryError.value = true;
      isFormValid = false;
    }

    if (selectedCities.isEmpty) {
      showCityError.value = true;
      isFormValid = false;
    }

    if (selectedType.value.isEmpty) {
      showTypeError.value = true;
      isFormValid = false;
    }

    if (!isFormValid) {
      PopUps.snackbar(
        texto: 'fill_required_fields'.tr,
        cor: Colors.red,
      );
      return;
    }

    await _submitUpdate(NewsStates.emAnalise);
  }

  Future<void> _submitUpdate(String status) async {
    try {
      // Prepara os dados atualizados
      final updatedData = {
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'body': jsonEncode(_bodyController.document.toDelta().toJson()),
        'cities': selectedCities.toList(),
        'categories': selectedCategories.toList(),
        'type': selectedType.value,
        'status': status,
        'updatedAt': DateTime.now(),
        'lastUpdated': DateTime.now(),
      };

      // Se foi selecionada nova imagem, adiciona ela
      if (_imageController.base64String != null) {
        updatedData['urlImages'] = [_imageController.base64String!];
      }

      // Chama o método do controller para atualizar
      String result =
          await _updateNewsController.updateNews(newsId, updatedData);

      if (result == "success") {
        PopUps.snackbar(
          texto: status == NewsStates.rascunho
              ? 'save_draft_news'.tr
              : 'news_updated_success'.tr,
          cor: Colors.green,
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        PopUps.snackbar(
          texto: result,
          cor: Colors.red,
        );
      }
    } catch (e) {
      PopUps.snackbar(
        texto: '${'unexpected_error'.tr}: $e',
        cor: Colors.red,
      );
    }
  }
}
