import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news/controller/create_news_form_controller.dart';
import 'package:redescomunicacionais/app/utils/components/markdown_editor.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/utils/theme/theme_controller.dart';

class CreateNewsPage extends GetView<CreateNewsFormController> {
  const CreateNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();
    final bool isLight = themeController.isLight;

    return Scaffold(
      backgroundColor: isLight ? theme.scaffoldBackgroundColor : null,
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        backgroundColor: isLight ? theme.scaffoldBackgroundColor : null,
        foregroundColor: theme.colorScheme.onSurface,
        flexibleSpace: isLight
            ? null
            : Container(
                decoration: BoxDecoration(
                  gradient: AppColors.appBarBottomGradient(),
                ),
              ),
        title: Text(
          'Adicionar Matéria'.tr,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface,
        ),
      ),
      body: Container(
        decoration: isLight
            ? const BoxDecoration(
                color: Colors.white,
              )
            : BoxDecoration(
                gradient: AppColors.darkBlueToBlackGradient(),
              ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleField(context, controller),
                  const SizedBox(height: 16),
                  
                  _buildSubtitleField(context, controller),
                  const SizedBox(height: 16),

                  // === CAMPOS PADRONIZADOS (TIPO COLABORADORES) ===
                  _buildCollaboratorsField(context, controller),
                  const SizedBox(height: 16),

                  _buildCategorySelection(context, controller),
                  const SizedBox(height: 16),

                  _buildCitySelection(context, controller),
                  const SizedBox(height: 16),

                  _buildTypeSelection(context, controller),
                  const SizedBox(height: 16),

                  _buildYouTubeUrlField(context, controller),
                  const SizedBox(height: 16),

                  _buildMarkdownEditor(context, controller),
                  const SizedBox(height: 16),

                  _buildImagePicker(context, controller),
                  const SizedBox(height: 16),

                  _buildImageInfo(context),
                  _buildImagePreview(context, controller),
                  const SizedBox(height: 16),

                  _buildImageMessage(context, controller),
                  const SizedBox(height: 16),

                  // === BOTÕES PADRONIZADOS (MATERIAL 3) ===
                  _buildPublishButton(context, controller),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COLABORADORES
  // ============================================================
  Widget _buildCollaboratorsField(BuildContext context, CreateNewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: () => _showCollaboratorsDialog(context, controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Colaboradores (Opcional)'.tr,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    if (controller.selectedCollaborators.isEmpty) {
                      return Text(
                        'Toque para adicionar colaboradores...'.tr,
                        style: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.8)),
                      );
                    }
                    return Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: controller.selectedCollaborators.map((name) {
                        return Chip(
                          label: Text(name, style: TextStyle(fontSize: 12, color: colors.onPrimaryContainer)),
                          backgroundColor: colors.primaryContainer,
                          deleteIcon: Icon(Icons.close, size: 16, color: colors.onPrimaryContainer),
                          onDeleted: () => controller.removeCollaborator(name),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
            Icon(Icons.people_alt_outlined, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _showCollaboratorsDialog(BuildContext context, CreateNewsFormController controller) {
    final manualInputController = TextEditingController();
    final theme = Theme.of(context);

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Adicionar Colaboradores'.tr, style: TextStyle(color: theme.colorScheme.onSurface)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: manualInputController,
                      decoration: InputDecoration(
                        hintText: 'Digitar nome manualmente...'.tr,
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                    icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
                    onPressed: () {
                      if (manualInputController.text.isNotEmpty) {
                        controller.addManualCollaborator(manualInputController.text);
                        manualInputController.clear();
                      }
                    },
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(),
              ),
              Text('Editores do Projeto:'.tr, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Obx(() => Column(
                    children: controller.availableEditors.map((editor) {
                      final isSelected = controller.selectedCollaborators.contains(editor);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(editor ?? "Nome não Informado", style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                        value: isSelected,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (_) => controller.toggleCollaborator(editor ?? "Nome não Informado"),
                      );
                    }).toList(),
                  )),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Concluir'.tr, style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORIAS
  // ============================================================
  Widget _buildCategorySelection(BuildContext context, CreateNewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showCategoryDialog(context, controller),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'select_categories'.tr,
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        if (controller.selectedCategories.isEmpty) {
                          return Text(
                            'Toque para selecionar...'.tr,
                            style: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.8)),
                          );
                        }
                        return Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: controller.selectedCategories.map((category) {
                            return Chip(
                              label: Text(category, style: TextStyle(fontSize: 12, color: colors.onPrimaryContainer)),
                              backgroundColor: colors.primaryContainer,
                              deleteIcon: Icon(Icons.close, size: 16, color: colors.onPrimaryContainer),
                              onDeleted: () => controller.toggleCategory(category),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
                Icon(Icons.category_outlined, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
        Obx(() {
          if (controller.showCategoryError) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('select_at_least_one_category'.tr, style: const TextStyle(color: Colors.red, fontSize: 12)),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  void _showCategoryDialog(BuildContext context, CreateNewsFormController controller) {
    final theme = Theme.of(context);

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('select_categories'.tr, style: TextStyle(color: theme.colorScheme.onSurface)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: controller.categories.map((category) {
                final isSelected = controller.selectedCategories.contains(category);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(category, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                  value: isSelected,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (_) => controller.toggleCategory(category),
                );
              }).toList(),
            )),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Concluir'.tr, style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CIDADE
  // ============================================================
  Widget _buildCitySelection(BuildContext context, CreateNewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showCityDialog(context, controller),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'select_city'.tr,
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        if (controller.selectedCities.isEmpty) {
                          return Text(
                            'Toque para selecionar...'.tr,
                            style: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.8)),
                          );
                        }
                        return Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: controller.selectedCities.map((city) {
                            return Chip(
                              label: Text(city, style: TextStyle(fontSize: 12, color: colors.onPrimaryContainer)),
                              backgroundColor: colors.primaryContainer,
                              deleteIcon: Icon(Icons.close, size: 16, color: colors.onPrimaryContainer),
                              onDeleted: () => controller.toggleCity(city),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
                Icon(Icons.location_city_outlined, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
        Obx(() {
          if (controller.showCityError) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('select_at_least_one_city'.tr, style: const TextStyle(color: Colors.red, fontSize: 12)),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  void _showCityDialog(BuildContext context, CreateNewsFormController controller) {
    final theme = Theme.of(context);

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('select_city'.tr, style: TextStyle(color: theme.colorScheme.onSurface)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: controller.cities.map((city) {
                final isSelected = controller.selectedCities.contains(city);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(city, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                  value: isSelected,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (_) => controller.toggleCity(city),
                );
              }).toList(),
            )),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Concluir'.tr, style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIPO
  // ============================================================
  Widget _buildTypeSelection(BuildContext context, CreateNewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showTypeDialog(context, controller),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'select_type'.tr,
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        if (controller.type == null || controller.type!.isEmpty) {
                          return Text(
                            'Toque para selecionar...'.tr,
                            style: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.8)),
                          );
                        }
                        return Chip(
                          label: Text(controller.type!, style: TextStyle(fontSize: 12, color: colors.onPrimaryContainer)),
                          backgroundColor: colors.primaryContainer,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }),
                    ],
                  ),
                ),
                Icon(Icons.label_outline, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
        Obx(() {
          if (controller.showTypeError) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('select_at_least_one_type'.tr, style: const TextStyle(color: Colors.red, fontSize: 12)),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  void _showTypeDialog(BuildContext context, CreateNewsFormController controller) {
    final theme = Theme.of(context);

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('select_type'.tr, style: TextStyle(color: theme.colorScheme.onSurface)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: controller.types.map((selectedType) {
                final isSelected = controller.type == selectedType;
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(selectedType, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                  value: isSelected,
                  activeColor: theme.colorScheme.primary,
                  // Tipo normalmente é seleção única, então sobrescrevemos e fechamos o modal (ou permite fechar no botão concluir)
                  onChanged: (_) {
                    controller.toggleType(selectedType);
                    Get.back();
                  },
                );
              }).toList(),
            )),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'.tr, style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TÍTULO E OUTROS CAMPOS DE TEXTO
  // ============================================================
  Widget _buildTitleField(BuildContext context, CreateNewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextFormField(
      controller: controller.titleController,
      style: TextStyle(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: 'title'.tr,
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.error, width: 2),
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

  Widget _buildSubtitleField(BuildContext context, CreateNewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextFormField(
      controller: controller.subtitleController,
      style: TextStyle(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: 'subtitle_optional'.tr,
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildYouTubeUrlField(BuildContext context, CreateNewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller.videoUrlController,
          style: TextStyle(color: colors.onSurface),
          decoration: InputDecoration(
            labelText: 'youtube_url_optional'.tr,
            labelStyle: TextStyle(color: colors.onSurfaceVariant),
            hintText: 'youtube_url_placeholder'.tr,
            hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.6)),
            prefixIcon: Icon(Icons.video_library, color: colors.onSurfaceVariant),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colors.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colors.primary, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('paste_youtube_link_here'.tr, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
      ],
    );
  }

  // ============================================================
  // EDITOR E IMAGEM
  // ============================================================
  Widget _buildMarkdownEditor(BuildContext context, CreateNewsFormController controller) {
    return SizedBox(
      height: 300,
      child: MarkdownEditor(controller: controller.bodyController),
    );
  }

  Widget _buildImagePicker(BuildContext context, CreateNewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          controller.imageController.pickImage();
        },
        icon: const Icon(Icons.image),
        label: Text('add_image'.tr),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildImageInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Text(
      'image_requirements'.tr,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.onSurface),
    );
  }

  Widget _buildImagePreview(BuildContext context, CreateNewsFormController controller) {
    return Center(
      child: Obx(() {
        if (controller.imageController.base64String != null) {
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  base64Decode(controller.imageController.base64String!),
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildImageMessage(BuildContext context, CreateNewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(() => Text(
        controller.imageController.message,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.secondary),
      ),
    );
  }

  // ============================================================
  // BOTÕES DE AÇÃO PADRONIZADOS (MATERIAL 3)
  // ============================================================
  Widget _buildPublishButton(BuildContext context, CreateNewsFormController controller) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () {
              controller.validateAndPublish(true);
            },
            icon: const Icon(Icons.save_outlined),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            label: Text(
              'save_draft_news'.tr,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              controller.validateAndPublish(false);
            },
            icon: const Icon(Icons.rocket_launch),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            label: Text(
              'publish_news'.tr,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}