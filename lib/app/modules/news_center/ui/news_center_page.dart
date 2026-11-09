import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news_center/controller/news_center_controller.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_bars.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_tones.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_list_mode.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/theme_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

class NewsCenterPage extends GetView<NewsCenterController> {
  const NewsCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: themeController.isLight
          ? theme.scaffoldBackgroundColor
          : null,

      appBar: AppBars.build(title: LocaleKeys.newsCenter.tr),
      body: Container(
        decoration: themeController.isLight
            ? BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        )
            : BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(context),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1,
                        children: [
                          _ActionCard(
                            title: LocaleKeys.createNewNews.tr,
                            subtitle: LocaleKeys.createNewNewsSubtitle.tr,
                            icon: Icons.create_rounded,
                            accentColor: AppTone.success.color,
                            onTap: () =>
                                Get.toNamed(Routes.CREATE_NEWS),
                          ),
                          _modeCard(NewsListMode.revision,
                              LocaleKeys.reviewNews.tr,
                              LocaleKeys.reviewNewsSubtitle.tr),
                          _modeCard(NewsListMode.drafts,
                              LocaleKeys.viewDrafts.tr,
                              LocaleKeys.viewDraftsSubtitle.tr),
                          _modeCard(NewsListMode.rejected,
                              LocaleKeys.viewRejected.tr,
                              LocaleKeys.viewRejectedSubtitle.tr),
                          _modeCard(NewsListMode.deleted,
                              LocaleKeys.viewDeleted.tr,
                              LocaleKeys.viewDeletedSubtitle.tr),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Card que abre a Home já filtrada; ícone e cor vêm do modo, para combinar
  // com a AppBar da lista
  Widget _modeCard(NewsListMode mode, String title, String subtitle) {
    return _ActionCard(
      title: title,
      subtitle: subtitle,
      icon: mode.icon,
      accentColor: mode.tone.color,
      onTap: () => controller.openNewsMode(mode),
    );
  }

  Widget _buildHero(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            child: Icon(
              Icons.newspaper_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.editorialPanel.tr,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.editorialPanelSubtitle.tr,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;

        final paddingValue =
        (cardWidth * 0.09).clamp(12.0, 20.0);

        final iconSize =
        (cardWidth * 0.16).clamp(24.0, 36.0);

        final titleFontSize =
        (cardWidth * 0.09).clamp(13.0, 18.0);

        final subtitleFontSize =
        (cardWidth * 0.07).clamp(11.0, 14.0);

        final bool isLight = themeController.isLight;

        return GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
          },
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _isPressed ? 0.85 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 10,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(paddingValue),
                    decoration: BoxDecoration(
                      // ==============================
                      // COR DO CARD
                      // ==============================
                      color: isLight
                          ? theme.colorScheme.surface
                          : Colors.white.withOpacity(0.06),

                      borderRadius: BorderRadius.circular(24),

                      // ==============================
                      // BORDA
                      // ==============================
                      border: Border.all(
                        color: _isPressed
                            ? widget.accentColor.withOpacity(0.55)
                            : isLight
                            ? theme.colorScheme.outlineVariant
                            : Colors.white.withOpacity(0.14),
                        width: 1,
                      ),

                      // ==============================
                      // SOMBRA
                      // ==============================
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            _isPressed ? 0.20 : 0.12,
                          ),
                          blurRadius: _isPressed ? 25 : 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                paddingValue * 0.6,
                              ),
                              decoration: BoxDecoration(
                                color: widget.accentColor
                                    .withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.icon,
                                size: iconSize,
                                color: widget.accentColor,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                theme.colorScheme.onSurface,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                height: 1.2,
                              ),
                            ),

                            SizedBox(
                              height: paddingValue * 0.3,
                            ),

                            Text(
                              widget.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: subtitleFontSize,
                                fontWeight: FontWeight.w400,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}