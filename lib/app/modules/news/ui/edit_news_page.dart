import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart'; // ← ADICIONE ESTE IMPORT
import 'package:redescomunicacionais/app/controller/image_controller.dart';
import 'package:redescomunicacionais/app/modules/news/controller/update_news_ontroller.dart';
import 'package:redescomunicacionais/app/utils/components/markdown_editor.dart';

class EditNewsPage extends StatefulWidget {
  const EditNewsPage({super.key});

  @override
  State<EditNewsPage> createState() => _EditNewsPageState();
}

class _EditNewsPageState extends State<EditNewsPage> {
  final _formKey = GlobalKey<FormState>();
  final UpdateNewsController _updateNewsController = Get.put(UpdateNewsController());
  final ImageController _imageController = Get.put(ImageController());
  
  // Controllers para os campos
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late QuillController _bodyController; // ← MUDANÇA AQUI: QuillController em vez de TextEditingController
  
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

  // Opções disponíveis
  final List<String> categories = [
    'Política', 'Economia', 'Esportes', 'Tecnologia', 'Saúde',
    'Educação', 'Cultura', 'Entretenimento', 'Ciência', 'Meio Ambiente'
  ];
  
  final List<String> cities = [
    'São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Brasília', 'Salvador',
    'Fortaleza', 'Curitiba', 'Manaus', 'Recife', 'Porto Alegre'
  ];
  
  final List<String> types = ['Notícia', 'Artigo', 'Reportagem', 'Editorial'];

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
    
    // ← MUDANÇA AQUI: Inicializa QuillController com conteúdo existente
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
    _bodyController.dispose(); // ← QuillController também tem dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Notícia"),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blue,
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                child: IntrinsicHeight(
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
                      _buildUpdateButton(),
                    ],
                  ),
                ),
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
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "O título é obrigatório.";
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
        labelText: "Subtítulo (opcional)",
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
            title: const Text(
              "Selecione as Categorias",
              style: TextStyle(color: Colors.white),
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            children: [
              Column(
                children: categories.map((category) {
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
                }).toList(),
              ),
            ],
          ),
        ),
        if (showCategoryError.value)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Selecione pelo menos uma categoria.",
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
            title: const Text(
              "Selecione a Cidade",
              style: TextStyle(color: Colors.white),
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            children: [
              Column(
                children: cities.map((city) {
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
                }).toList(),
              ),
            ],
          ),
        ),
        if (showCityError.value)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Selecione pelo menos uma cidade.",
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
            title: const Text(
              "Selecione o Tipo",
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
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Selecione pelo menos um tipo.",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    ));
  }

  Widget _buildMarkdownEditor() {
    return Expanded(
      child: MarkdownEditor(controller: _bodyController), // ← Agora funciona corretamente
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _imageController.pickImage(),
        icon: const Icon(Icons.image),
        label: const Text(
          "Alterar Imagem",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildImageInfo() {
    return const Text(
      "A imagem deve estar no formato JPG ou JPEG e, preferencialmente, ter um tamanho máximo de 500 KB. Imagens maiores serão comprimidas, o que pode causar perda de qualidade e lentidão no carregamento. Para uma melhor visualização, recomenda-se o uso de imagens com orientação paisagem.",
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

  Widget _buildUpdateButton() {
    return Obx(() => ElevatedButton(
      onPressed: _updateNewsController.isLoading.value ? null : _validateAndUpdate,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: _updateNewsController.isLoading.value ? Colors.grey : Colors.blue,
      ),
      child: _updateNewsController.isLoading.value
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "Atualizar Notícia",
              style: TextStyle(color: Colors.white),
            ),
    ));
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
  void _validateAndUpdate() async {
    // Reset erros
    showCategoryError.value = false;
    showCityError.value = false;
    showTypeError.value = false;

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
      Get.snackbar(
        "Erro de Validação",
        "Por favor, preencha todos os campos obrigatórios.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Prepara os dados atualizados
      final updatedData = {
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'body': jsonEncode(_bodyController.document.toDelta().toJson()), // ← MUDANÇA AQUI: Converte Delta para JSON
        'cities': selectedCities.toList(),
        'categories': selectedCategories.toList(),
        'type': selectedType.value,
        'status': 'publicado',
        'updatedAt': DateTime.now(),
      };

      // Se foi selecionada nova imagem, adiciona ela
      if (_imageController.base64String != null) {
        updatedData['urlImages'] = [_imageController.base64String!];
      }

      // Chama o método do controller para atualizar
      String result = await _updateNewsController.updateNews(newsId, updatedData);

      if (result == "success") {
        Get.snackbar(
          "Sucesso",
          "Notícia atualizada com sucesso",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Volta para a página anterior
        Get.back();
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