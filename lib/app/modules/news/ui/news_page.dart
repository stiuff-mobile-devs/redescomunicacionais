import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';

import 'package:redescomunicacionais/app/services/youtube_service.dart';
import 'package:redescomunicacionais/app/utils/responsive_utils.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/utils/theme/theme_controller.dart';

class NewsPage extends GetView<NewsController> {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();

    final bool isLight = themeController.isLight;

    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final bool isTablet = ResponsiveUtils.isTablet(screenWidth);
    final bool isWideScreen = screenWidth > 900;

    final bool hasMoreThanTwoCategories =
        controller.selectedNews.categories.length > 2;

    final List<String> visibleCategories = controller.selectedNews.categories
        .map<String>((e) => e.toString())
        .take(2)
        .toList();

    final List<String>? visibleCollaborators = controller
        .selectedNews.collaborators
        ?.map<String>((e) => e.toString())
        .take(2)
        .toList();

    return GetBuilder<NewsController>(
      init: controller,
      initState: (_) {
        try {
          controller.quillController?.dispose();
        } catch (_) {}

        controller.startQuillController();
      },
      dispose: (_) {
        try {
          controller.quillController?.dispose();
        } catch (_) {}
      },
      builder: (_) {
        if (controller.quillController == null) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            flexibleSpace: isLight
                ? null
                : Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.appBarBottomGradient(),
                    ),
                  ),
            title: Text(
              '${'full_type'.tr} ${controller.selectedNews.type}',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: ResponsiveUtils.calculateAppBarTitleSize(
                  screenWidth,
                  isTablet,
                  false,
                ),
              ),
            ),
            iconTheme: IconThemeData(
              color: theme.colorScheme.onSurface,
              size: ResponsiveUtils.calculateIconSize(
                screenWidth,
                isTablet,
              ),
            ),
            centerTitle: true,
            toolbarHeight: isTablet ? 70.0 : 56.0,
          ),
          body: isWideScreen
              ? _buildWideScreenLayout(
                  screenWidth,
                  screenHeight,
                  isTablet,
                  visibleCategories,
                  hasMoreThanTwoCategories,
                  context,
                  isLight,
                  visibleCollaborators,
                )
              : _buildMobileLayout(
                  screenWidth,
                  screenHeight,
                  isTablet,
                  visibleCategories,
                  hasMoreThanTwoCategories,
                  context,
                  isLight,
                  visibleCollaborators
                ),
        );
      },
    );
  }

  // ============================================================
  // LAYOUT WIDE SCREEN
  // ============================================================

  Widget _buildWideScreenLayout(
    double screenWidth,
    double screenHeight,
    bool isTablet,
    List<String> visibleCategories,
    bool hasMoreThanTwoCategories,
    BuildContext context,
    bool isLight,
    List<String>? visibleCollaborators,
  ) {
    final theme = Theme.of(context);

    final String urlImages = controller.selectedNews.urlImages.isNotEmpty
        ? controller.selectedNews.urlImages.first
        : '';

    final List<String> cities = controller.selectedNews.cities;

    return Row(
      children: [
        // ======================================================
        // LADO ESQUERDO
        // ======================================================

        SizedBox(
          width: screenWidth * 0.4,
          height: screenHeight,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNewsImage(
                  urlImages: urlImages,
                  cities: cities,
                  isTablet: isTablet,
                ),

                SizedBox(height: isTablet ? 25 : 20),

                // TÍTULO
                Text(
                  controller.selectedNews.title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 32 : 28,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isTablet ? 12 : 10),

                // SUBTÍTULO
                Text(
                  controller.selectedNews.subtitle ?? '',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: isTablet ? 20 : 18,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isTablet ? 25 : 20),

                // INFORMAÇÕES
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.calculateResponsiveBorderRadius(
                            isTablet,
                          ) *
                          0.8,
                    ),
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: isTablet ? 20 : 18,
                          ),
                          SizedBox(width: isTablet ? 8 : 6),
                          Text(
                            '${'info_of'.tr} ${controller.selectedNews.type}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 12 : 10),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              theme.colorScheme.outlineVariant,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 12 : 10),
                      _buildInfoRowWideScreen(
                        isTablet,
                        visibleCategories,
                        hasMoreThanTwoCategories,
                        context,
                        visibleCollaborators,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 40 : 32),
              ],
            ),
          ),
        ),

        // ======================================================
        // DIVISOR
        // ======================================================

        Container(
          width: 1,
          height: screenHeight,
          color: theme.colorScheme.outlineVariant,
        ),

        // ======================================================
        // LADO DIREITO
        // ======================================================

        Expanded(
          child: Container(
            height: screenHeight,
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'content_of'.tr} ${controller.selectedNews.type}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 16),
                  if (controller.selectedNews.videoUrl != null &&
                      controller.selectedNews.videoUrl!.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(
                        bottom: isTablet ? 20 : 16,
                      ),
                      child: YouTubeMiniPlayer(
                        videoUrl: controller.selectedNews.videoUrl!,
                        width: double.infinity,
                        height: isTablet ? 200 : 160,
                        autoPlay: false,
                        mute: false,
                        enableCaption: true,
                        captionLanguage: 'pt',
                      ),
                    ),
                  _buildQuillContent(
                    context: context,
                    isTablet: isTablet,
                    isLight: isLight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LAYOUT MOBILE
  // ============================================================

  Widget _buildMobileLayout(
    double screenWidth,
    double screenHeight,
    bool isTablet,
    List<String> visibleCategories,
    bool hasMoreThanTwoCategories,
    BuildContext context,
    bool isLight,
    List<String>? visibleCollaborators,
  ) {
    final theme = Theme.of(context);

    final String urlImages = controller.selectedNews.urlImages.isNotEmpty
        ? controller.selectedNews.urlImages.first
        : '';

    final List<String> cities = controller.selectedNews.cities;

    return ListView(
      padding: ResponsiveUtils.calculateResponsivePadding(
        screenWidth,
        screenHeight,
        isTablet,
      ),
      children: [
        // ======================================================
        // IMAGEM
        // ======================================================

        _buildNewsImage(
          urlImages: urlImages,
          cities: cities,
          isTablet: isTablet,
        ),

        SizedBox(height: isTablet ? 25 : 20),

        // ======================================================
        // TÍTULO
        // ======================================================

        Text(
          controller.selectedNews.title,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 32 : 28,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isTablet ? 12 : 10),

        // ======================================================
        // SUBTÍTULO
        // ======================================================

        Text(
          controller.selectedNews.subtitle ?? '',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: isTablet ? 20 : 18,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isTablet ? 25 : 20),

        // ======================================================
        // INFORMAÇÕES
        // ======================================================

        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.calculateResponsiveBorderRadius(isTablet) * 0.8,
            ),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: isTablet ? 20 : 18,
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                  Text(
                    '${'info_of'.tr} ${controller.selectedNews.type}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 12 : 10),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      theme.colorScheme.outlineVariant,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 12 : 10),
              _buildInfoRow(
                isTablet,
                visibleCategories,
                hasMoreThanTwoCategories,
                context,
                visibleCollaborators,
              ),
            ],
          ),
        ),

        SizedBox(height: isTablet ? 25 : 20),

        // ======================================================
        // YOUTUBE
        // ======================================================

        if (controller.selectedNews.videoUrl != null &&
            controller.selectedNews.videoUrl!.isNotEmpty)
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            child: YouTubeMiniPlayer(
              videoUrl: controller.selectedNews.videoUrl!,
              width: screenWidth * 0.9,
              height: isTablet ? 220 : 180,
              autoPlay: false,
              mute: false,
              enableCaption: true,
              captionLanguage: 'pt',
            ),
          ),

        SizedBox(height: isTablet ? 25 : 20),

        // ======================================================
        // CONTEÚDO
        // ======================================================

        _buildQuillContent(
          context: context,
          isTablet: isTablet,
          isLight: isLight,
        ),
      ],
    );
  }

  // ============================================================
  // IMAGEM DA NOTÍCIA
  // ============================================================

  Widget _buildNewsImage({
    required String urlImages,
    required List<String> cities,
    required bool isTablet,
  }) {
    final double imageHeight = isTablet ? 250 : 200;

    Widget image;

    if (urlImages.isNotEmpty) {
      try {
        image = Image.memory(
          base64Decode(urlImages),
          fit: BoxFit.cover,
          width: double.infinity,
          height: imageHeight,
          errorBuilder: (_, __, ___) {
            return _buildFallbackImage(
              cities: cities,
              isTablet: isTablet,
            );
          },
        );
      } catch (_) {
        image = _buildFallbackImage(
          cities: cities,
          isTablet: isTablet,
        );
      }
    } else {
      image = _buildFallbackImage(
        cities: cities,
        isTablet: isTablet,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        ResponsiveUtils.calculateResponsiveBorderRadius(isTablet) * 0.8,
      ),
      child: image,
    );
  }

  // ============================================================
  // FALLBACK DA IMAGEM
  // ============================================================

  Widget _buildFallbackImage({
    required List<String> cities,
    required bool isTablet,
  }) {
    final double imageHeight = isTablet ? 250 : 200;

    final String asset = cities.isNotEmpty && cities.first.isNotEmpty
        ? controller.getCityImageAsset(cities.first)
        : controller.getCityImageAsset('default');

    return Image.asset(
      asset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: imageHeight,
      errorBuilder: (_, __, ___) {
        return Container(
          width: double.infinity,
          height: imageHeight,
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            size: 50,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  // ============================================================
  // CONTEÚDO QUILL
  // ============================================================

  Widget _buildQuillContent({
    required BuildContext context,
    required bool isTablet,
    required bool isLight,
  }) {
    final theme = Theme.of(context);

    final Color contentBackground =
        isLight ? Colors.white : const Color(0xFF1E1E1E);

    final Color contentTextColor = isLight ? Colors.black87 : Colors.white;

    final Color borderColor =
        isLight ? Colors.grey.shade300 : const Color(0xFF333333);

    return Container(
      decoration: BoxDecoration(
        color: contentBackground,
        border: Border.all(
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.calculateResponsiveBorderRadius(isTablet) * 0.5,
        ),
      ),
      child: AbsorbPointer(
        child: QuillEditor.basic(
          controller: controller.quillController!,
          focusNode: FocusNode(),
          scrollController: ScrollController(),
          config: QuillEditorConfig(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            autoFocus: false,
            expands: false,
            enableInteractiveSelection: false,
            customStyles: DefaultStyles(
              // ==================================================
              // PARÁGRAFO
              // ==================================================

              paragraph: DefaultTextBlockStyle(
                TextStyle(
                  color: contentTextColor,
                  fontSize: isTablet ? 18 : 16,
                ),
                HorizontalSpacing.zero,
                const VerticalSpacing(6, 0),
                const VerticalSpacing(0, 0),
                null,
              ),

              // ==================================================
              // NEGRITO
              // ==================================================

              bold: TextStyle(
                color: contentTextColor,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 18 : 16,
              ),

              // ==================================================
              // ITÁLICO
              // ==================================================

              italic: TextStyle(
                color: contentTextColor,
                fontStyle: FontStyle.italic,
                fontSize: isTablet ? 18 : 16,
              ),

              // ==================================================
              // SUBLINHADO
              // ==================================================

              underline: TextStyle(
                color: contentTextColor,
                decoration: TextDecoration.underline,
                decorationColor: contentTextColor,
                fontSize: isTablet ? 18 : 16,
              ),

              // ==================================================
              // CITAÇÃO
              // ==================================================

              quote: DefaultTextBlockStyle(
                TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: isTablet ? 18 : 16,
                ),
                HorizontalSpacing.zero,
                const VerticalSpacing(6, 6),
                const VerticalSpacing(0, 0),
                BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 4,
                    ),
                  ),
                ),
              ),

              // ==================================================
              // LISTAS
              // ==================================================

              lists: DefaultListBlockStyle(
                TextStyle(
                  color: contentTextColor,
                  fontSize: isTablet ? 18 : 16,
                ),
                HorizontalSpacing.zero,
                const VerticalSpacing(6, 0),
                const VerticalSpacing(0, 0),
                const BoxDecoration(
                  color: Colors.transparent,
                ),
                null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFORMAÇÕES - WIDE SCREEN
  // ============================================================

  Widget _buildInfoRowWideScreen(
    bool isTablet,
    List<String> visibleCategories,
    bool hasMoreThanTwoCategories,
    BuildContext context,
    List<String>? visibleCollaborators,
  ) {
    return Column(
      children: [
        _buildInfoItem(
          icon: Icons.person_outline,
          label: 'author'.tr,
          value: controller.selectedNews.author,
          isTablet: isTablet,
          theme: Theme.of(context),
        ),
        SizedBox(height: isTablet ? 12 : 10),
        _buildInfoItem(
          icon: Icons.schedule,
          label: 'date'.tr,
          value: DateFormat('dd/MM/yyyy').format(
            controller.selectedNews.createdAt,
          ),
          isTablet: isTablet,
          theme: Theme.of(context),
        ),
        SizedBox(height: isTablet ? 12 : 10),
        _buildInfoItem(
          icon: Icons.location_city,
          label: 'city'.tr,
          value: controller.selectedNews.cities.isNotEmpty
              ? controller.selectedNews.cities.first
              : '',
          isTablet: isTablet,
          theme: Theme.of(context),
        ),
        SizedBox(height: isTablet ? 12 : 10),
        _buildInfoItem(
          icon: Icons.category,
          label: 'type'.tr,
          value: controller.selectedNews.type,
          isTablet: isTablet,
          theme: Theme.of(context),
        ),
        SizedBox(height: isTablet ? 12 : 10),
        _buildCategoriesItem(
          isTablet,
          controller.selectedNews.categories
              .map<String>((e) => e.toString())
              .toList(),
          visibleCategories,
          hasMoreThanTwoCategories,
          context,
        ),
        if (controller.selectedNews.collaborators != 0)
          _buildCollaboratorsItem(
              isTablet,
              controller.selectedNews.collaborators
                  ?.map<String>((e) => e.toString())
                  .toList(),
              visibleCollaborators,
              hasMoreThanTwoCategories,
              context,
            ),
      ],
    );
  }

  // ============================================================
  // INFORMAÇÕES - MOBILE
  // ============================================================

  Widget _buildInfoRow(
    bool isTablet,
    List<String> visibleCategories,
    bool hasMoreThanTwoCategories,
    BuildContext context,
    List<String>? visibleCollaborators,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // AUTOR + DATA
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.person_outline,
                label: 'author'.tr,
                value: controller.selectedNews.author,
                isTablet: isTablet,
                theme: theme,
              ),
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.schedule,
                label: 'date'.tr,
                value: DateFormat('dd/MM/yyyy').format(
                  controller.selectedNews.createdAt,
                ),
                isTablet: isTablet,
                theme: theme,
              ),
            ),
          ],
        ),

        SizedBox(height: isTablet ? 12 : 10),

        // CIDADE + TIPO
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.location_city,
                label: 'city'.tr,
                value: controller.selectedNews.cities.isNotEmpty
                    ? controller.selectedNews.cities.first
                    : '',
                isTablet: isTablet,
                theme: theme,
              ),
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.category,
                label: 'type'.tr,
                value: controller.selectedNews.type,
                isTablet: isTablet,
                theme: theme,
              ),
            ),
          ],
        ),

        SizedBox(height: isTablet ? 12 : 10),

        // CATEGORIAS
        _buildCategoriesItem(
          isTablet,
          controller.selectedNews.categories
              .map<String>((e) => e.toString())
              .toList(),
          visibleCategories,
          hasMoreThanTwoCategories,
          context,
        ),
        if ( controller.selectedNews.collaborators?.length != 0)

          _buildCollaboratorsItem(
            isTablet,
            controller.selectedNews.collaborators
                ?.map<String>((e) => e.toString())
                .toList(),
            visibleCollaborators,
            hasMoreThanTwoCategories,
            context,
          ),

        SizedBox(height: isTablet ? 12 : 10),

        // REVISOR
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.supervisor_account,
                label: 'reviewer'.tr,
                value: controller.selectedNews.validatedByName ?? '',
                isTablet: isTablet,
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ITEM DE INFORMAÇÃO
  // ============================================================

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isTablet,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 10 : 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.calculateResponsiveBorderRadius(isTablet) * 0.5,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.onSurfaceVariant,
                size: isTablet ? 16 : 14,
              ),
              SizedBox(width: isTablet ? 6 : 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORIAS
  // ============================================================

  Widget _buildCategoriesItem(
    bool isTablet,
    List<String> categorias,
    List<String> visibleCategories,
    bool hasMoreThanTwoCategories,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 10 : 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.calculateResponsiveBorderRadius(isTablet) * 0.5,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.label_outline,
                color: theme.colorScheme.onSurfaceVariant,
                size: isTablet ? 16 : 14,
              ),
              SizedBox(width: isTablet ? 6 : 4),
              Text(
                categorias.length > 1 ? 'categories'.tr : 'category'.tr,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: isTablet ? 12 : 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ...visibleCategories.map(
                (cat) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 8 : 6,
                    vertical: isTablet ? 4 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.calculateResponsiveBorderRadius(
                            isTablet,
                          ) *
                          0.3,
                    ),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: isTablet ? 13 : 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (hasMoreThanTwoCategories)
                GestureDetector(
                  onTap: () {
                    _showAllCategoriesDialog(
                      context,
                      categorias,
                      isTablet,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 8 : 6,
                      vertical: isTablet ? 4 : 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.calculateResponsiveBorderRadius(
                              isTablet,
                            ) *
                            0.3,
                      ),
                      border: Border.all(
                        color: Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+${categorias.length - 2}',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: isTablet ? 13 : 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.more_horiz,
                          color: Colors.orange,
                          size: isTablet ? 14 : 12,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorsItem(
    bool isTablet,
    List<String>? collaborators,
    List<String>? visibleCollaborators,
    bool hasMoreThanTwoCategories,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 10 : 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.calculateResponsiveBorderRadius(isTablet) * 0.5,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.label_outline,
                color: theme.colorScheme.onSurfaceVariant,
                size: isTablet ? 16 : 14,
              ),
              SizedBox(width: isTablet ? 6 : 4),
              Text(
                'Colaboradores',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: isTablet ? 12 : 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ...(visibleCollaborators ?? []).map(
                (cat) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 8 : 6,
                    vertical: isTablet ? 4 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.calculateResponsiveBorderRadius(
                              isTablet) *
                          0.3,
                    ),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: isTablet ? 13 : 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (hasMoreThanTwoCategories)
                GestureDetector(
                  onTap: () {
                    _showAllCollaboratorsDialog(
                      context,
                      collaborators,
                      isTablet,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 8 : 6,
                      vertical: isTablet ? 4 : 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.calculateResponsiveBorderRadius(
                              isTablet,
                            ) *
                            0.3,
                      ),
                      border: Border.all(
                        color: Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+${collaborators?.length ?? 0}',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: isTablet ? 13 : 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.more_horiz,
                          color: Colors.orange,
                          size: isTablet ? 14 : 12,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllCollaboratorsDialog(
    BuildContext context,
    List<String>? collaborators,
    bool isTablet,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return ResponsiveUtils.createResponsiveDialog(
          context: context,
          title: 'all_categories'.tr,
          content: collaborators?.join(', ') ?? '',
          onConfirm: () => Navigator.of(context).pop(),
          confirmText: 'close'.tr,
        );
      },
    );
  }
  // ============================================================
  // DIALOG CATEGORIAS
  // ============================================================

  void _showAllCategoriesDialog(
    BuildContext context,
    List<String> categorias,
    bool isTablet,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return ResponsiveUtils.createResponsiveDialog(
          context: context,
          title: 'all_categories'.tr,
          content: categorias.join(', '),
          onConfirm: () => Navigator.of(context).pop(),
          confirmText: 'close'.tr,
        );
      },
    );
  }
}
