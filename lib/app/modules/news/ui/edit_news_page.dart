import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:redescomunicacionais/app/controller/image_controller.dart';
import 'package:redescomunicacionais/app/modules/news/controller/update_news_ontroller.dart'; // ← MUDANÇA AQUI

class EditNewsPage extends StatefulWidget {
  const EditNewsPage({super.key});

  @override
  State<EditNewsPage> createState() => _EditNewsPageState();
}

class _EditNewsPageState extends State<EditNewsPage> {
  final _formKey = GlobalKey<FormState>();
  final UpdateNewsController _updateNewsController = Get.put(UpdateNewsController()); // ← MUDANÇA AQUI
  final ImageController _imageController = Get.put(ImageController());
  
  // Controllers para os campos
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _authorController;
  late QuillController _bodyController;
  
  // Dados da notícia
  late String newsId;
  late String originalImageUrl;
  late List<String> selectedCities;
  late List<String> selectedCategories;
  late String selectedType;
  late String selectedStatus;

  // Opções
  final List<String> cities = [
    'São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Brasília', 'Salvador',
    'Fortaleza', 'Curitiba', 'Manaus', 'Recife', 'Porto Alegre'
  ];
  
  final List<String> categories = [
    'Política', 'Economia', 'Esportes', 'Tecnologia', 'Saúde', 
    'Educação', 'Cultura', 'Entretenimento', 'Ciência', 'Meio Ambiente'
  ];
  
  final List<String> types = ['Notícia', 'Artigo', 'Reportagem', 'Editorial'];
  final List<String> status = ['rascunho', 'publicado', 'arquivado'];

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
    _authorController = TextEditingController(text: args['autor'] ?? '');
    
    // Carrega o corpo da notícia no QuillController
    _bodyController = QuillController.basic();
    if (args['corpo'] != null && args['corpo'].isNotEmpty) {
      try {
        final deltaJson = jsonDecode(args['corpo']);
        final document = Document.fromJson(deltaJson);
        _bodyController = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Se falhar, usa como texto simples
        _bodyController.document.insert(0, args['corpo']);
      }
    }
    
    // Carrega listas
    selectedCities = List<String>.from(args['cidade'] is String 
        ? args['cidade'].split(', ') 
        : args['cidade'] ?? []);
    selectedCategories = List<String>.from(args['categoria'] is String 
        ? args['categoria'].split(', ') 
        : args['categoria'] ?? []);
    selectedType = args['type'] ?? 'Notícia';
    selectedStatus = args['status'] ?? 'rascunho';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _authorController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Editar Notícia",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          // Botão salvar
          Obx(() => IconButton(
            onPressed: _updateNewsController.isLoading.value ? null : _saveNews, // ← MUDANÇA AQUI
            icon: _updateNewsController.isLoading.value // ← MUDANÇA AQUI
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
          )),
        ],
      ),
      body: Stack(
        children: [
          // Conteúdo principal
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.blue, Colors.black],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo Título
                    _buildTextField(
                      controller: _titleController,
                      label: "Título",
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Título é obrigatório';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Campo Subtítulo
                    _buildTextField(
                      controller: _subtitleController,
                      label: "Subtítulo",
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Subtítulo é obrigatório';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Campo Autor
                    _buildTextField(
                      controller: _authorController,
                      label: "Autor",
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Autor é obrigatório';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Seleção de Imagem
                    _buildImageSection(),

                    const SizedBox(height: 16),

                    // Dropdowns em linha (responsivo)
                    MediaQuery.of(context).size.width < 600
                        ? Column(children: _buildDropdowns())
                        : Row(
                            children: _buildDropdowns()
                                .map((widget) => Expanded(child: widget))
                                .toList(),
                          ),

                    const SizedBox(height: 16),

                    // Multi-select para Cidades
                    _buildMultiSelect(
                      title: "Cidades",
                      options: cities,
                      selectedItems: selectedCities,
                      onChanged: (selected) {
                        setState(() {
                          selectedCities = selected;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Multi-select para Categorias
                    _buildMultiSelect(
                      title: "Categorias",
                      options: categories,
                      selectedItems: selectedCategories,
                      onChanged: (selected) {
                        setState(() {
                          selectedCategories = selected;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Editor de texto rico
                    _buildRichTextEditor(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          Obx(() {
            if (_updateNewsController.isLoading.value) { // ← MUDANÇA AQUI
              return Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        "Salvando alterações...",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Imagem da Notícia",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        // Imagem atual ou selecionada
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Obx(() {
              // Se foi selecionada nova imagem
              if (_imageController.base64String != null) {
                return Image.memory(
                  base64Decode(_imageController.base64String!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              }
              // Senão, mostra imagem original
              else if (originalImageUrl.isNotEmpty) {
                try {
                  return Image.memory(
                    base64Decode(originalImageUrl),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                } catch (e) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.image, color: Colors.grey, size: 50),
                  );
                }
              }
              // Placeholder
              else {
                return Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.add_photo_alternate, color: Colors.grey, size: 50),
                );
              }
            }),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Botão para selecionar nova imagem
        ElevatedButton.icon(
          onPressed: () => _imageController.pickImage(),
          icon: const Icon(Icons.photo_library),
          label: const Text("Alterar Imagem"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        
        // Mensagem do ImageController
        Obx(() {
          if (_imageController.message.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _imageController.message,
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  List<Widget> _buildDropdowns() {
    return [
      // Dropdown Tipo
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: DropdownButtonFormField<String>(
          value: selectedType,
          decoration: const InputDecoration(
            labelText: "Tipo",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          items: types.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedType = value!;
            });
          },
        ),
      ),
      
      const SizedBox(height: 16),

      // Dropdown Status
      Padding(
        padding: const EdgeInsets.only(left: 8),
        child: DropdownButtonFormField<String>(
          value: selectedStatus,
          decoration: const InputDecoration(
            labelText: "Status",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          items: status.map((stat) {
            return DropdownMenuItem(value: stat, child: Text(stat));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedStatus = value!;
            });
          },
        ),
      ),
    ];
  }

  Widget _buildMultiSelect({
    required String title,
    required List<String> options,
    required List<String> selectedItems,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedItems.contains(option);
              return GestureDetector(
                onTap: () {
                  List<String> newSelected = List.from(selectedItems);
                  if (isSelected) {
                    newSelected.remove(option);
                  } else {
                    newSelected.add(option);
                  }
                  onChanged(newSelected);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRichTextEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Conteúdo da Notícia",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Toolbar
              QuillSimpleToolbar(
                controller: _bodyController,
                config: const QuillSimpleToolbarConfig(
                  toolbarIconAlignment: WrapAlignment.start,
                  multiRowsDisplay: false,
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showStrikeThrough: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showClearFormat: false,
                  showListNumbers: false,
                  showListBullets: true,
                  showQuote: true,
                  showIndent: false,
                  showLink: false,
                  showUndo: true,
                  showRedo: true,
                  showFontFamily: false,
                  showFontSize: false,
                  showHeaderStyle: false,
                  showCodeBlock: false,
                  showInlineCode: false,
                  showDirection: false,
                  showSearchButton: false,
                  showSubscript: false,
                  showSuperscript: false,
                ),
              ),
              // Editor
              Container(
                height: 300,
                padding: const EdgeInsets.all(12),
                child: QuillEditor.basic(
                  controller: _bodyController,
                  focusNode: FocusNode(),
                  scrollController: ScrollController(),
                  config: QuillEditorConfig(
                    padding: EdgeInsets.zero,
                    autoFocus: false,
                    expands: false,
                    customStyles: DefaultStyles(
                      paragraph: DefaultTextBlockStyle(
                        const TextStyle(color: Colors.white, fontSize: 16),
                        HorizontalSpacing.zero,
                        const VerticalSpacing(6, 0),
                        const VerticalSpacing(0, 0),
                        null,
                      ),
                      bold: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      italic: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                      underline: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                      quote: DefaultTextBlockStyle(
                        const TextStyle(color: Colors.white70),
                        HorizontalSpacing.zero,
                        const VerticalSpacing(6, 6),
                        const VerticalSpacing(0, 0),
                        BoxDecoration(
                          border: Border(left: BorderSide(color: Colors.white, width: 4)),
                        ),
                      ),
                      lists: DefaultListBlockStyle(
                        const TextStyle(color: Colors.white, fontSize: 16),
                        HorizontalSpacing.zero,
                        const VerticalSpacing(6, 0),
                        const VerticalSpacing(0, 0),
                        const BoxDecoration(color: Colors.transparent),
                        null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _saveNews() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCities.isEmpty) {
      Get.snackbar("Erro", "Selecione pelo menos uma cidade");
      return;
    }

    if (selectedCategories.isEmpty) {
      Get.snackbar("Erro", "Selecione pelo menos uma categoria");
      return;
    }

    try {
      // Prepara os dados atualizados
      final updatedData = {
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'author': _authorController.text.trim(),
        'body': jsonEncode(_bodyController.document.toDelta().toJson()),
        'cities': selectedCities,
        'categories': selectedCategories,
        'type': selectedType,
        'status': selectedStatus,
        'updatedAt': DateTime.now(),
      };

      // Se foi selecionada nova imagem, adiciona ela
      if (_imageController.base64String != null) {
        updatedData['urlImages'] = [_imageController.base64String!];
      }

      // Chama o método do UpdateNewsController
      String result = await _updateNewsController.updateNews(newsId, updatedData); // ← MUDANÇA AQUI

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