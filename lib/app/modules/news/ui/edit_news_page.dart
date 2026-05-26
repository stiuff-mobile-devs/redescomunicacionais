import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';

import 'package:redescomunicacionais/app/modules/news/controller/update_news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';
import 'package:redescomunicacionais/app/services/image_base64_service.dart';
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

  final ImageBase64Service _imageController =
  Get.put(ImageBase64Service());

  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late QuillController _bodyController;

  late String newsId;
  late String originalImageUrl;

  final RxList<String> selectedCategories = <String>[].obs;
  final RxList<String> selectedCities = <String>[].obs;
  final RxString selectedType = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadNewsData();
  }

  void _loadNewsData() {
    final args = Get.arguments as Map<String, dynamic>;

    newsId = args['newsId'] ?? '';
    originalImageUrl = args['imgurl'] ?? '';

    _titleController =
        TextEditingController(text: args['titulo'] ?? '');

    _subtitleController =
        TextEditingController(text: args['subtitulo'] ?? '');

    _bodyController = QuillController.basic();

    if (args['corpo'] != null && args['corpo'].toString().isNotEmpty) {
      try {
        final deltaJson = jsonDecode(args['corpo']);
        final document = Document.fromJson(deltaJson);

        _bodyController = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _bodyController.document.insert(0, args['corpo']);
      }
    }

    selectedCities.value = List<String>.from(
      args['cidade'] is String
          ? args['cidade'].split(', ')
          : args['cidade'] ?? [],
    );

    selectedCategories.value = List<String>.from(
      args['categoria'] is String
          ? args['categoria'].split(', ')
          : args['categoria'] ?? [],
    );

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
        title: const Text("Editar Notícia"),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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

                  _buildMarkdownEditor(),
                  const SizedBox(height: 16),

                  _buildImagePicker(),
                  const SizedBox(height: 16),

                  _buildImagePreview(),
                  const SizedBox(height: 16),

                  _buildImageMessage(),
                  const SizedBox(height: 24),

                  _buildUpdateButton(),
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
        labelText: "Título",
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "O título é obrigatório";
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
        labelText: "Subtítulo",
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildMarkdownEditor() {
    return SizedBox(
      height: 300,
      child: MarkdownEditor(
        controller: _bodyController,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _imageController.pickImages(),
        icon: const Icon(Icons.image),
        label: const Text("Selecionar imagens"),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Obx(() {
      if (_imageController.base64Images.isNotEmpty) {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _imageController.base64Images.map((image) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(image),
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            );
          }).toList(),
        );
      }

      if (originalImageUrl.isNotEmpty) {
        try {
          List<dynamic> originalImages = [];

          try {
            originalImages = jsonDecode(originalImageUrl);
          } catch (_) {
            originalImages = [originalImageUrl];
          }

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: originalImages.map<Widget>((image) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(image),
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          );
        } catch (e) {
          return const SizedBox.shrink();
        }
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildImageMessage() {
    return Obx(
          () => Text(
        _imageController.message,
        style: const TextStyle(
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Obx(
          () => ElevatedButton(
        onPressed: _updateNewsController.isLoading.value
            ? null
            : _validateAndUpdate,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor:
          _updateNewsController.isLoading.value
              ? Colors.grey
              : Colors.blue,
        ),
        child: _updateNewsController.isLoading.value
            ? const BlinkingLoadingIcon(
          size: 26,
          color: Colors.white,
        )
            : const Text(
          "Atualizar Notícia",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _validateAndUpdate() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    try {
      final updatedData = {
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'body': jsonEncode(
          _bodyController.document.toDelta().toJson(),
        ),
        'cities': selectedCities.toList(),
        'categories': selectedCategories.toList(),
        'type': selectedType.value,
        'status': NewsStates.emAnalise,
        'updatedAt': DateTime.now(),
      };

      if (_imageController.base64Images.isNotEmpty) {
        updatedData['urlImages'] =
            _imageController.base64Images.toList();
      }

      String result = await _updateNewsController.updateNews(
        newsId,
        updatedData,
      );

      if (result == "success") {
        Get.snackbar(
          "Sucesso",
          "Notícia atualizada com sucesso",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        Get.snackbar(
          "Erro",
          result,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Erro inesperado: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}