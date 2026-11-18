import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_form_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_labels.dart';
import 'package:redescomunicacionais/app/modules/utils/components/markdown_editor.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/theme_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_bars.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_tones.dart';

// Formulário único: criar matéria (sem argumentos) ou editar ({'newsId': id})
class NewsFormPage extends GetView<NewsFormController> {
  const NewsFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();
    final bool isLight = themeController.isLight;

    return Scaffold(
      backgroundColor: isLight ? theme.scaffoldBackgroundColor : null,
      appBar: AppBars.build(
        title: (Get.arguments is Map ? LocaleKeys.editNews : LocaleKeys.addNews).tr,
        tone: AppTone.success,
      ),
      body: Obx(() => controller.isLoadingNews.value
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(context, isLight)),
    );
  }

  Widget _buildForm(BuildContext context, bool isLight) {
    return Container(
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
                  _buildSubmittedHint(context),
                  _buildPublishButton(context, controller),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      );
  }

  // Editando matéria já enviada: explica que o rascunho vira uma cópia
  Widget _buildSubmittedHint(BuildContext context) {
    if (!controller.isEditingSubmitted) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              LocaleKeys.draftCopyHint.tr,
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLABORADORES
  // ============================================================
  Widget _buildCollaboratorsField(BuildContext context, NewsFormController controller) {
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
                    LocaleKeys.collaboratorsOptional.tr,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    if (controller.selectedCollaborators.isEmpty) {
                      return Text(
                        LocaleKeys.tapToAddCollaborators.tr,
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

  Future<void> _showCollaboratorsDialog(BuildContext context, NewsFormController controller) async {
    final theme = Theme.of(context);

    await AppPopups.sheet<void>(
      title: LocaleKeys.addCollaborators.tr,
      icon: Icons.people_alt_outlined,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // O campo é dono do próprio controlador (descartado quando a janela
          // sai da tela; descartar logo após o await causava "_dependents.isEmpty")
          _ManualCollaboratorField(onAdd: controller.addManualCollaborator),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(),
          ),
          Text(LocaleKeys.projectEditors.tr, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 8),
          Obx(() => Column(
            children: controller.availableEditors.map((editor) {
              final isSelected = controller.selectedCollaborators.contains(editor);
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(editor, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                value: isSelected,
                activeColor: theme.colorScheme.primary,
                onChanged: (_) => controller.toggleCollaborator(editor),
              );
            }).toList(),
          )),
        ],
      ),
      actions: (ctx) => [
        AppSheetButton.primary(
          label: LocaleKeys.done.tr,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORIAS
  // ============================================================
  Widget _buildCategorySelection(BuildContext context, NewsFormController controller) {
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
                        LocaleKeys.selectCategories.tr,
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        if (controller.selectedCategories.isEmpty) {
                          return Text(
                            LocaleKeys.tapToSelect.tr,
                            style: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.8)),
                          );
                        }
                        return Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: controller.selectedCategories.map((category) {
                            return Chip(
                              label: Text(NewsLabels.category(category), style: TextStyle(fontSize: 12, color: colors.onPrimaryContainer)),
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
              child: Text(LocaleKeys.selectAtLeastOneCategory.tr, style: const TextStyle(color: Colors.red, fontSize: 12)),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  void _showCategoryDialog(BuildContext context, NewsFormController controller) {
    final theme = Theme.of(context);

    AppPopups.sheet<void>(
      title: LocaleKeys.selectCategories.tr,
      icon: Icons.category_outlined,
      child: Obx(() => Column(
        mainAxisSize: MainAxisSize.min,
        children: controller.categories.map((category) {
          final isSelected = controller.selectedCategories.contains(category);
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(NewsLabels.category(category), style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
            value: isSelected,
            activeColor: theme.colorScheme.primary,
            onChanged: (_) => controller.toggleCategory(category),
          );
        }).toList(),
      )),
      actions: (ctx) => [
        AppSheetButton.primary(
          label: LocaleKeys.done.tr,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
    );
  }

  // ============================================================
  // CIDADE
  // ============================================================
  Widget _buildCitySelection(BuildContext context, NewsFormController controller) {
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
                        LocaleKeys.selectCity.tr,
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        if (controller.selectedCities.isEmpty) {
                          return Text(
                            LocaleKeys.tapToSelect.tr,
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
              child: Text(LocaleKeys.selectAtLeastOneCity.tr, style: const TextStyle(color: Colors.red, fontSize: 12)),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  void _showCityDialog(BuildContext context, NewsFormController controller) {
    final theme = Theme.of(context);

    AppPopups.sheet<void>(
      title: LocaleKeys.selectCity.tr,
      icon: Icons.location_city_outlined,
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
      actions: (ctx) => [
        AppSheetButton.primary(
          label: LocaleKeys.done.tr,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
    );
  }

  // ============================================================
  // TIPO
  // ============================================================
  Widget _buildTypeSelection(BuildContext context, NewsFormController controller) {
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
                        LocaleKeys.selectType.tr,
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        if (controller.type == null || controller.type!.isEmpty) {
                          return Text(
                            LocaleKeys.tapToSelect.tr,
                            style: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.8)),
                          );
                        }
                        return Chip(
                          label: Text(NewsLabels.type(controller.type), style: TextStyle(fontSize: 12, color: colors.onPrimaryContainer)),
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
              child: Text(LocaleKeys.selectAtLeastOneType.tr, style: const TextStyle(color: Colors.red, fontSize: 12)),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // Tipo é seleção única: escolher fecha a folha
  Future<void> _showTypeDialog(BuildContext context, NewsFormController controller) async {
    final String? selectedType = await AppPopups.choose<String>(
      title: LocaleKeys.selectType.tr,
      icon: Icons.label_outline,
      selected: controller.type,
      options: controller.types
          .map((type) => PopupOption(value: type, label: NewsLabels.type(type)))
          .toList(),
    );

    if (selectedType != null) controller.toggleType(selectedType);
  }

  // ============================================================
  // TÍTULO E OUTROS CAMPOS DE TEXTO
  // ============================================================
  Widget _buildTitleField(BuildContext context, NewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextFormField(
      controller: controller.titleController,
      style: TextStyle(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: LocaleKeys.title.tr,
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
          return LocaleKeys.titleRequired.tr;
        }
        return null;
      },
    );
  }

  Widget _buildSubtitleField(BuildContext context, NewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextFormField(
      controller: controller.subtitleController,
      style: TextStyle(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: LocaleKeys.subtitleOptional.tr,
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

  Widget _buildYouTubeUrlField(BuildContext context, NewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller.videoUrlController,
          style: TextStyle(color: colors.onSurface),
          decoration: InputDecoration(
            labelText: LocaleKeys.youtubeUrlOptional.tr,
            labelStyle: TextStyle(color: colors.onSurfaceVariant),
            hintText: LocaleKeys.youtubeUrlPlaceholder.tr,
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
        Text(LocaleKeys.pasteYoutubeLinkHere.tr, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
      ],
    );
  }

  // ============================================================
  // EDITOR E IMAGEM
  // ============================================================
  Widget _buildMarkdownEditor(BuildContext context, NewsFormController controller) {
    return SizedBox(
      height: 300,
      child: MarkdownEditor(controller: controller.bodyController),
    );
  }

  Widget _buildImagePicker(BuildContext context, NewsFormController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          controller.imageController.pickImage();
        },
        icon: const Icon(Icons.image),
        label: Obx(() => Text(controller.imageController.base64String != null
            ? LocaleKeys.changeImage.tr
            : LocaleKeys.addImage.tr)),
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
      LocaleKeys.imageRequirements.tr,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.onSurface),
    );
  }

  Widget _buildImagePreview(BuildContext context, NewsFormController controller) {
    return Center(
      child: Obx(() {
        final String? image = controller.imageController.base64String;
        if (image == null) return const SizedBox.shrink();
        try {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              base64Decode(image),
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          );
        } catch (_) {
          // Imagem salva corrompida: não mostra a prévia
          return const SizedBox.shrink();
        }
      }),
    );
  }

  Widget _buildImageMessage(BuildContext context, NewsFormController controller) {
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
  Widget _buildPublishButton(BuildContext context, NewsFormController controller) {
    // Botões desabilitados enquanto salva (evita matéria duplicada)
    return Obx(() {
      final bool saving = controller.isSaving.value;
      return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: saving ? null : controller.saveDraft,
            icon: const Icon(Icons.save_outlined),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            label: Text(
              LocaleKeys.saveDraft.tr,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: saving ? null : controller.submitForReview,
            icon: const Icon(Icons.rocket_launch),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            label: Text(
              (controller.isEditing.value
                      ? LocaleKeys.updateNews
                      : LocaleKeys.publishNews)
                  .tr,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
    });
  }
}

// Campo para digitar o nome de um colaborador. O controlador vive com o
// widget e só é descartado quando a janela de colaboradores sai da tela.
class _ManualCollaboratorField extends StatefulWidget {
  final void Function(String name) onAdd;

  const _ManualCollaboratorField({required this.onAdd});

  @override
  State<_ManualCollaboratorField> createState() =>
      _ManualCollaboratorFieldState();
}

class _ManualCollaboratorFieldState extends State<_ManualCollaboratorField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    if (_controller.text.trim().isEmpty) return;
    widget.onAdd(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (_) => _add(),
            decoration: InputDecoration(
              hintText: LocaleKeys.typeNameManually.tr,
              isDense: true,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          icon: const Icon(Icons.add),
          onPressed: _add,
        ),
      ],
    );
  }
}