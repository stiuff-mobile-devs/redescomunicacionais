import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:redescomunicacionais/app/modules/utils/news/categories.dart';
import 'package:redescomunicacionais/app/modules/utils/news/cities_codes.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_types.dart';
import 'package:redescomunicacionais/app/services/image_base64_service.dart';
import 'package:redescomunicacionais/app/modules/news/controller/update_news_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_labels.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_states.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:redescomunicacionais/app/modules/utils/components/markdown_editor.dart';
import 'package:redescomunicacionais/app/modules/utils/widgets/blinking_loading_icon.dart';

class EditNewsPage extends StatefulWidget {
  const EditNewsPage({super.key});

  @override
  State<EditNewsPage> createState() => _EditNewsPageState();
}

class _EditNewsPageState extends State<EditNewsPage> {
  // ============================================================
  // COR FIXA PARA OS CABEÇALHOS DOS SELETORES
  //
  // Independe do tema (claro/clássico) — sempre azul escuro.
  // ============================================================

  static const Color _brandBlue = Color(0xFF0D1B4C);

  // ============================================================
  // FORM
  // ============================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final UpdateNewsController _updateNewsController =
  Get.put(UpdateNewsController());

  final ImageBase64Service _imageController =
  Get.put(ImageBase64Service());

  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late QuillController _bodyController;

  // ============================================================
  // DADOS DA NOTÍCIA
  // ============================================================

  late String newsId;
  late String originalImageUrl;

  // ============================================================
  // SELEÇÕES
  // ============================================================

  final RxList selectedCategories = [].obs;
  final RxList selectedCities = [].obs;
  final RxString selectedType = ''.obs;

  // ============================================================
  // ERROS
  // ============================================================

  final RxBool showCategoryError = false.obs;
  final RxBool showCityError = false.obs;
  final RxBool showTypeError = false.obs;

  // ============================================================
  // EXPANSÕES
  // ============================================================

  final RxBool _categoryExpanded = false.obs;
  final RxBool _cityExpanded = false.obs;
  final RxBool _typeExpanded = false.obs;

  // ============================================================
  // LISTAS
  // ============================================================

  final List<String> categories = Categories.all;

  final List<String> cities = CitiesCodes().cities.values.toList();

  final List<String> types = NewsTypes().types;

  @override
  void initState() {
    super.initState();
    _loadNewsData();
  }

  // ============================================================
  // CARREGA DADOS
  // ============================================================

  void _loadNewsData() {
    final args = Get.arguments as Map<String, dynamic>;

    newsId = args['newsId']?.toString() ?? '';
    originalImageUrl = args['imgurl']?.toString() ?? '';

    // ------------------------------------------------------------
    // TÍTULO
    // ------------------------------------------------------------

    _titleController = TextEditingController(
      text: args['titulo']?.toString() ?? '',
    );

    // ------------------------------------------------------------
    // SUBTÍTULO
    // ------------------------------------------------------------

    _subtitleController = TextEditingController(
      text: args['subtitulo']?.toString() ?? '',
    );

    // ------------------------------------------------------------
    // CORPO
    // ------------------------------------------------------------

    _bodyController = QuillController.basic();

    final corpo = args['corpo'];

    if (corpo != null && corpo.toString().trim().isNotEmpty) {
      try {
        final deltaJson = jsonDecode(corpo.toString());

        final document = Document.fromJson(
          List<dynamic>.from(deltaJson),
        );

        _bodyController = QuillController(
          document: document,
          selection: const TextSelection.collapsed(
            offset: 0,
          ),
        );
      } catch (_) {
        _bodyController.document.insert(
          0,
          corpo.toString(),
        );
      }
    }

    // ------------------------------------------------------------
    // CIDADES
    // ------------------------------------------------------------

    selectedCities.value = _parseList(
      args['cidade'],
    );

    // ------------------------------------------------------------
    // CATEGORIAS
    // ------------------------------------------------------------

    selectedCategories.value = _parseList(
      args['categoria'],
    );

    // ------------------------------------------------------------
    // TIPO
    // ------------------------------------------------------------

    selectedType.value = args['type']?.toString() ?? '';
  }

  // ============================================================
  // CONVERTE STRING/LISTA
  // ============================================================

  List<String> _parseList(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is String) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _bodyController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        centerTitle: true,
        elevation: theme.appBarTheme.elevation,
        title: Text(
          LocaleKeys.editNews.tr,
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Container(
        width: double.infinity,
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
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

                    const SizedBox(height: 8),

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
      ),
    );
  }

  // ============================================================
  // TÍTULO
  // ============================================================

  Widget _buildTitleField() {
    final colors = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _titleController,

      style: TextStyle(
        color: colors.onSurface,
      ),

      decoration: InputDecoration(
        labelText: LocaleKeys.title.tr,

        labelStyle: TextStyle(
          color: colors.onSurfaceVariant,
        ),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colors.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colors.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return LocaleKeys.titleRequired.tr;
        }

        return null;
      },
    );
  }

  // ============================================================
  // SUBTÍTULO
  // ============================================================

  Widget _buildSubtitleField() {
    final colors = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _subtitleController,

      style: TextStyle(
        color: colors.onSurface,
      ),

      decoration: InputDecoration(
        labelText: LocaleKeys.subtitleOptional.tr,

        labelStyle: TextStyle(
          color: colors.onSurfaceVariant,
        ),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colors.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colors.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ============================================================
  // FUNDO DOS SELETORES
  //
  // IMPORTANTE:
  // Aqui usamos o surface do ColorScheme do tema.
  //
  // Tema clássico:
  // surface = Color(0xff1E1E1E)
  //
  // Tema claro:
  // surface = Colors.white
  //
  // Portanto os três seletores acompanham automaticamente
  // o tema ativo.
  // ============================================================

  Color _selectionBackgroundColor(
      ThemeData theme,
      ) {
    return theme.scaffoldBackgroundColor;
  }

  // ============================================================
  // CONTAINER DOS SELETORES
  // ============================================================

  Widget _selectionContainer({
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor =
    _selectionBackgroundColor(theme);

    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: backgroundColor,

        border: Border.all(
          color: colors.outline,
        ),

        borderRadius: BorderRadius.circular(8),
      ),

      clipBehavior: Clip.antiAlias,

      child: child,
    );
  }

  // ============================================================
  // CATEGORIAS
  // ============================================================

  Widget _buildCategorySelection() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor =
    _selectionBackgroundColor(theme);

    return Obx(
          () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selectionContainer(
            child: Column(
              children: [
                Material(
                  color: backgroundColor,

                  child: InkWell(
                    splashColor:
                    colors.primary.withAlpha(35),

                    highlightColor:
                    colors.primary.withAlpha(20),

                    onTap: () {
                      _categoryExpanded.value =
                      !_categoryExpanded.value;
                    },

                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),

                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              LocaleKeys.selectCategories.tr,

                              style: const TextStyle(
                                color: _brandBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          Icon(
                            _categoryExpanded.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,

                            color: _brandBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (_categoryExpanded.value)
                  Container(
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: backgroundColor,

                      border: Border(
                        top: BorderSide(
                          color: colors.outline,
                        ),
                      ),
                    ),

                    child: Column(
                      children: categories.map(
                            (category) {
                          final selected =
                          selectedCategories.contains(
                            category,
                          );

                          return Material(
                            color: backgroundColor,

                            child: InkWell(
                              splashColor:
                              colors.primary.withAlpha(35),

                              highlightColor:
                              colors.primary.withAlpha(20),

                              onTap: () {
                                toggleCategory(category);
                              },

                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),

                                child: Row(
                                  children: [
                                    _buildCustomCheckbox(
                                      selected: selected,
                                      colors: colors,
                                    ),

                                    const SizedBox(
                                      width: 12,
                                    ),

                                    Expanded(
                                      child: Text(
                                        NewsLabels.category(category),

                                        style: TextStyle(
                                          color:
                                          colors.onSurface,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
              ],
            ),
          ),

          if (showCategoryError.value)
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                left: 4,
              ),

              child: Text(
                LocaleKeys.selectAtLeastOneCategory.tr,

                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CIDADES
  // ============================================================

  Widget _buildCitySelection() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor =
    _selectionBackgroundColor(theme);

    return Obx(
          () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selectionContainer(
            child: Column(
              children: [
                Material(
                  color: backgroundColor,

                  child: InkWell(
                    splashColor:
                    colors.primary.withAlpha(35),

                    highlightColor:
                    colors.primary.withAlpha(20),

                    onTap: () {
                      _cityExpanded.value =
                      !_cityExpanded.value;
                    },

                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),

                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              LocaleKeys.selectCity.tr,

                              style: const TextStyle(
                                color: _brandBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          Icon(
                            _cityExpanded.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,

                            color: _brandBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (_cityExpanded.value)
                  Container(
                    width: double.infinity,

                    constraints: const BoxConstraints(
                      maxHeight: 220,
                    ),

                    decoration: BoxDecoration(
                      color: backgroundColor,

                      border: Border(
                        top: BorderSide(
                          color: colors.outline,
                        ),
                      ),
                    ),

                    child: ListView(
                      shrinkWrap: true,

                      children: cities.map(
                            (city) {
                          final selected =
                          selectedCities.contains(city);

                          return Material(
                            color: backgroundColor,

                            child: InkWell(
                              splashColor:
                              colors.primary.withAlpha(35),

                              highlightColor:
                              colors.primary.withAlpha(20),

                              onTap: () {
                                toggleCity(city);
                              },

                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),

                                child: Row(
                                  children: [
                                    _buildCustomCheckbox(
                                      selected: selected,
                                      colors: colors,
                                    ),

                                    const SizedBox(
                                      width: 12,
                                    ),

                                    Expanded(
                                      child: Text(
                                        city,

                                        style: TextStyle(
                                          color:
                                          colors.onSurface,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
              ],
            ),
          ),

          if (showCityError.value)
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                left: 4,
              ),

              child: Text(
                LocaleKeys.selectAtLeastOneCity.tr,

                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TIPO
  // ============================================================

  Widget _buildTypeSelection() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor =
    _selectionBackgroundColor(theme);

    return Obx(
          () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selectionContainer(
            child: Column(
              children: [
                Material(
                  color: backgroundColor,

                  child: InkWell(
                    splashColor:
                    colors.primary.withAlpha(35),

                    highlightColor:
                    colors.primary.withAlpha(20),

                    onTap: () {
                      _typeExpanded.value =
                      !_typeExpanded.value;
                    },

                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),

                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              LocaleKeys.selectType.tr,

                              style: const TextStyle(
                                color: _brandBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          Icon(
                            _typeExpanded.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,

                            color: _brandBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (_typeExpanded.value)
                  Container(
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: backgroundColor,

                      border: Border(
                        top: BorderSide(
                          color: colors.outline,
                        ),
                      ),
                    ),

                    child: Column(
                      children: types.map(
                            (type) {
                          final selected =
                              selectedType.value == type;

                          return Material(
                            color: backgroundColor,

                            child: InkWell(
                              splashColor:
                              colors.primary.withAlpha(35),

                              highlightColor:
                              colors.primary.withAlpha(20),

                              onTap: () {
                                toggleType(type);
                              },

                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),

                                child: Row(
                                  children: [
                                    _buildCustomCheckbox(
                                      selected: selected,
                                      colors: colors,
                                    ),

                                    const SizedBox(
                                      width: 12,
                                    ),

                                    Expanded(
                                      child: Text(
                                        NewsLabels.type(type),

                                        style: TextStyle(
                                          color:
                                          colors.onSurface,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
              ],
            ),
          ),

          if (showTypeError.value)
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                left: 4,
              ),

              child: Text(
                LocaleKeys.selectAtLeastOneType.tr,

                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CHECKBOX PERSONALIZADO
  // ============================================================

  Widget _buildCustomCheckbox({
    required bool selected,
    required ColorScheme colors,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),

      width: 22,
      height: 22,

      decoration: BoxDecoration(
        color: selected
            ? colors.primary
            : Colors.transparent,

        border: Border.all(
          color: selected
              ? colors.primary
              : colors.outline,

          width: 2,
        ),

        borderRadius: BorderRadius.circular(4),
      ),

      child: selected
          ? Icon(
        Icons.check,
        size: 16,
        color: colors.onPrimary,
      )
          : null,
    );
  }

  // ============================================================
  // EDITOR
  // ============================================================

  Widget _buildMarkdownEditor() {
    return SizedBox(
      height: 300,

      child: MarkdownEditor(
        controller: _bodyController,
      ),
    );
  }

  // ============================================================
  // SELECIONAR IMAGEM
  // ============================================================

  Widget _buildImagePicker() {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          _imageController.pickImage();
        },

        icon: const Icon(
          Icons.image,
        ),

        label: Text(
          LocaleKeys.changeImage.tr,

          style: TextStyle(
            color: colors.onPrimary,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFORMAÇÕES DA IMAGEM
  // ============================================================

  Widget _buildImageInfo() {
    final colors = Theme.of(context).colorScheme;

    return Text(
      LocaleKeys.imageRequirements.tr,

      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colors.onSurface,
      ),
    );
  }

  // ============================================================
  // PREVIEW DA IMAGEM
  // ============================================================

  Widget _buildImagePreview() {
    return Center(
      child: Obx(
            () {
          // ------------------------------------------------------
          // NOVA IMAGEM
          // ------------------------------------------------------

          if (_imageController.base64String != null) {
            try {
              return Column(
                children: [
                  Image.memory(
                    base64Decode(
                      _imageController.base64String!,
                    ),
                    height: 150,
                  ),
                ],
              );
            } catch (_) {
              return const SizedBox.shrink();
            }
          }

          // ------------------------------------------------------
          // IMAGEM ORIGINAL
          // ------------------------------------------------------

          if (originalImageUrl.isNotEmpty) {
            try {
              return Column(
                children: [
                  Image.memory(
                    base64Decode(
                      originalImageUrl,
                    ),
                    height: 150,
                  ),
                ],
              );
            } catch (_) {
              return const SizedBox.shrink();
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ============================================================
  // MENSAGEM DA IMAGEM
  // ============================================================

  Widget _buildImageMessage() {
    final colors = Theme.of(context).colorScheme;

    return Obx(
          () => Text(
        _imageController.message,

        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: colors.secondary,
        ),
      ),
    );
  }

  // ============================================================
  // BOTÕES
  // ============================================================

  Widget _buildActionButtons() {
    final colors = Theme.of(context).colorScheme;

    return Obx(
          () {
        final isLoading =
            _updateNewsController.isLoading.value;

        return Row(
          children: [
            // ==================================================
            // RASCUNHO
            // ==================================================

            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                  _validateAndUpdate(true);
                },

                icon: Icon(
                  Icons.save_outlined,
                  color: colors.onSurface,
                ),

                label: Text(
                  LocaleKeys.saveDraft.tr,

                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                style: OutlinedButton.styleFrom(
                  minimumSize:
                  const Size(double.infinity, 52),

                  foregroundColor:
                  colors.onSurface,

                  side: BorderSide(
                    color: colors.outline,
                    width: 1.4,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ==================================================
            // ATUALIZAR
            // ==================================================

            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(14),

                  boxShadow: [
                    BoxShadow(
                      color:
                      colors.primary.withAlpha(100),
                      blurRadius: 16,
                      offset:
                      const Offset(0, 6),
                    ),
                  ],
                ),

                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                    _validateAndUpdate(false);
                  },

                  style:
                  ElevatedButton.styleFrom(
                    minimumSize:
                    const Size(
                      double.infinity,
                      52,
                    ),

                    backgroundColor:
                    isLoading
                        ? colors.surface
                        : colors.primary,

                    foregroundColor:
                    colors.onPrimary,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),

                  icon: isLoading
                      ? BlinkingLoadingIcon(
                    size: 22,
                    color:
                    colors.onSurface,
                  )
                      : Icon(
                    Icons.update,
                    color:
                    colors.onPrimary,
                  ),

                  label: Text(
                    LocaleKeys.updateNews.tr,

                    style: TextStyle(
                      color:
                      colors.onPrimary,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // TOGGLE CATEGORIA
  // ============================================================

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }

    showCategoryError.value = false;
  }

  // ============================================================
  // TOGGLE CIDADE
  // ============================================================

  void toggleCity(String city) {
    if (selectedCities.contains(city)) {
      selectedCities.remove(city);
    } else {
      selectedCities.add(city);
    }

    showCityError.value = false;
  }

  // ============================================================
  // TOGGLE TIPO
  // ============================================================

  void toggleType(String type) {
    selectedType.value =
    selectedType.value == type ? '' : type;

    showTypeError.value = false;
  }

  // ============================================================
  // VALIDAÇÃO
  // ============================================================

  Future<void> _validateAndUpdate(
      bool draft,
      ) async {
    showCategoryError.value = false;
    showCityError.value = false;
    showTypeError.value = false;

    // ----------------------------------------------------------
    // RASCUNHO
    // ----------------------------------------------------------

    if (draft) {
      await _submitUpdate(
        NewsStates.rascunho,
      );

      return;
    }

    // ----------------------------------------------------------
    // FORMULÁRIO
    // ----------------------------------------------------------

    bool isFormValid =
        _formKey.currentState?.validate() ?? false;

    // ----------------------------------------------------------
    // CATEGORIA
    // ----------------------------------------------------------

    if (selectedCategories.isEmpty) {
      showCategoryError.value = true;
      isFormValid = false;
    }

    // ----------------------------------------------------------
    // CIDADE
    // ----------------------------------------------------------

    if (selectedCities.isEmpty) {
      showCityError.value = true;
      isFormValid = false;
    }

    // ----------------------------------------------------------
    // TIPO
    // ----------------------------------------------------------

    if (selectedType.value.isEmpty) {
      showTypeError.value = true;
      isFormValid = false;
    }

    // ----------------------------------------------------------
    // INVÁLIDO
    // ----------------------------------------------------------

    if (!isFormValid) {
      AppPopups.error(LocaleKeys.fillRequiredFields.tr);

      return;
    }

    // ----------------------------------------------------------
    // ATUALIZA
    // ----------------------------------------------------------

    await _submitUpdate(
      NewsStates.emAnalise,
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submitUpdate(
      String status,
      ) async {
    try {
      final Map<String, dynamic> updatedData = {
        'title': _titleController.text.trim(),

        'subtitle': _subtitleController.text.trim(),

        'body': jsonEncode(
          _bodyController.document
              .toDelta()
              .toJson(),
        ),

        'cities': selectedCities.toList(),

        'categories':
        selectedCategories.toList(),

        'type': selectedType.value,

        'status': status,

        'updatedAt': DateTime.now(),

        'lastUpdated': DateTime.now(),
      };

      // --------------------------------------------------------
      // NOVA IMAGEM
      // --------------------------------------------------------

      if (_imageController.base64String != null) {
        updatedData['urlImages'] = [
          _imageController.base64String!,
        ];
      }

      // --------------------------------------------------------
      // ATUALIZA
      // --------------------------------------------------------

      final String result =
      await _updateNewsController.updateNews(
        newsId,
        updatedData,
      );

      // --------------------------------------------------------
      // SUCESSO
      // --------------------------------------------------------

      if (result == 'success') {
        AppPopups.success(status == NewsStates.rascunho
            ? LocaleKeys.draftSavedSuccess.tr
            : LocaleKeys.newsUpdatedSuccess.tr);

        if (mounted) {
          Navigator.of(context).pop();
        }

        return;
      }

      // --------------------------------------------------------
      // ERRO
      // --------------------------------------------------------

      // `result` traz o detalhe técnico do erro: vai só para o log
      debugPrint(result);
      AppPopups.error(LocaleKeys.newsUpdateError.tr);
    } catch (e) {
      debugPrint('Erro inesperado ao atualizar a matéria: $e');
      AppPopups.error(LocaleKeys.unexpectedError.tr);
    }
  }
}