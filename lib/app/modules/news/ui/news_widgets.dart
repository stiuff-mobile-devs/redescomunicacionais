import 'dart:convert';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_labels.dart';
import 'package:redescomunicacionais/app/modules/utils/news/news_states.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/app_translations.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:redescomunicacionais/app/modules/utils/widgets/blinking_loading_icon.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/theme_controller.dart';

class NewsWidgets extends GetView<NewsController> {
  final String? selectedCity; // Recebe a cidade selecionada na Home

  const NewsWidgets({super.key, this.selectedCity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();
    final bool isLight = themeController.isLight;

    final Color pageBackground = isLight
        ? theme.scaffoldBackgroundColor
        : Colors.transparent;

    final Color newsCardColor = isLight
        ? theme.colorScheme.surface
        : const Color(0xFF121212);

    return Scaffold(
      backgroundColor: pageBackground,
      body: Container(
        decoration: isLight
            ? BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        )
            : BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Obx(
              () {
            if (!controller.initialLoadDone.value ||
                (controller.isLoading.value && controller.isAllListsEmpty())) {
              return Center(
                child: BlinkingLoadingIcon(
                  size: 36,
                  color: theme.colorScheme.onSurface,
                ),
              );
            }

            if (controller.isAllListsEmpty()) {
              return _buildEmptyState(theme);
            }

            List<NewsModel> selectedNewss = controller.getNewsForCurrentMode();

            // Filtra as notícias pela cidade selecionada (se não for nula e nem 'Todas')
            if (selectedCity != null && selectedCity != 'Todas') {
              selectedNewss = selectedNewss.where((news) {
                return news.cities.isNotEmpty && news.cities.contains(selectedCity);
              }).toList();
            }

            if (selectedNewss.isEmpty) {
              return _buildEmptyState(theme);
            }

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                controller.selectedCardIndex.value = null;
              },
              child: ListView(
                controller: ScrollController(),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 16.0),
                  // Lista vertical de notícias
                  ..._buildNewsList(selectedNewss, theme),

                  if (controller.homeController.isPublishedMode.value &&
                      selectedNewss.isNotEmpty)
                    _buildCreateMoreItem(theme),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Rolável para que o RefreshIndicator da Home funcione mesmo sem notícias
  Widget _buildEmptyState(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Text(
              LocaleKeys.noNewsAvailable.tr,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNewsList(
      List<NewsModel> validNews,
      ThemeData theme,
      ) {
    return validNews.asMap().entries.map<Widget>(
      (entry) {
        int index = entry.key;
        NewsModel news = entry.value;

        return Obx(() {
          final bool isSelected = controller.isSelected(index);
          final List<_CardAction> actions = _newsActions(news);

          return GestureDetector(
            // Com o pop-up aberto, tocar no card só fecha o pop-up
            onTap: () => isSelected
                ? controller.selectedCardIndex.value = null
                : controller.openNews(news),
            // Toque longo abre as ações sobre o banner (se houver alguma)
            onLongPress: actions.isEmpty
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    controller.toggleSelected(index);
                  },
            child: AnimatedScale(
              scale: isSelected ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Card(
                    color: theme.colorScheme.surface,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    elevation: isSelected ? 8.0 : 4.0,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: isSelected
                          ? BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2.0,
                            )
                          : BorderSide.none,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 200.0,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              news.urlImages.isNotEmpty &&
                                      news.urlImages[0].isNotEmpty
                                  ? _buildSafeImage(news.urlImages[0], 200.0)
                                  : Image.asset(
                                      controller.getCityImageAsset(
                                          news.cities.isNotEmpty
                                              ? news.cities[0]
                                              : 'default'),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 200.0,
                                    ),
                              // Pop-up de ações sobre o banner
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: isSelected
                                    ? _buildBannerActions(actions)
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                news.subtitle ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 14.0,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                _getFormattedDate(news.createdAt.toString()),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          );
        });
      },
    ).toList();
  }

  Widget _buildCreateMoreItem(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        controller.getMoreNews();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.loadMoreNews.tr,
              style: theme.textTheme.bodyLarge,
            )
          ],
        ),
      ),
    );
  }

  // Ações disponíveis para a matéria (definem o pop-up do toque longo)
  List<_CardAction> _newsActions(NewsModel news) {
    return [
      if (controller.canEdit(news))
        _CardAction(
          icon: Icons.edit_outlined,
          label: LocaleKeys.edit.tr,
          color: Colors.blue.shade600,
          onTap: () => controller.openEditNews(news),
        ),
      if (controller.canDelete(news))
        _CardAction(
          icon: Icons.delete_outline_rounded,
          label: LocaleKeys.delete.tr,
          color: Colors.red.shade600,
          onTap: () => _hideNewsPopup(
              news.id, controller.user.email!, news.createdBy, news.type),
        ),
      if (controller.canReReview(news))
        _CardAction(
          icon: Icons.rate_review_outlined,
          label: LocaleKeys.review.tr,
          color: Colors.amber.shade700,
          onTap: () => _showReviewDialog(news),
        ),
      if (controller.homeController.isRejectedMode.value)
        _CardAction(
          icon: Icons.sticky_note_2_outlined,
          label: LocaleKeys.observations.tr,
          color: Colors.orange.shade700,
          onTap: () => _showObservationDialog(news.rejectedObservation),
        ),
    ];
  }

  // Camada desfocada sobre o banner com os botões de ação
  Widget _buildBannerActions(List<_CardAction> actions) {
    void close() => controller.selectedCardIndex.value = null;

    return GestureDetector(
      key: const ValueKey('banner-actions'),
      behavior: HitTestBehavior.opaque,
      onTap: close,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.black.withValues(alpha: 0.55),
            child: Stack(
              children: [
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: close,
                  ),
                ),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 12,
                    children: actions.map((action) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: action.color,
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                close();
                                action.onTap();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Icon(
                                  action.icon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            action.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _hideNewsPopup(
      String newsId, String userEmail, String authorEmail, String type) async {
    final bool confirmed = await AppPopups.confirm(
      title: LocaleKeys.deleteType.trParams({'type': NewsLabels.type(type)}),
      message: LocaleKeys.confirmDeleteType
          .trParams({'type': NewsLabels.type(type).toLowerCase()}),
      icon: Icons.delete_outline_rounded,
      confirmText: LocaleKeys.delete.tr,
      destructive: true,
    );

    if (!confirmed) return;

    await controller.hideNews(
      newsId: newsId,
      status: NewsStates.deletado,
      userEmail: userEmail,
      type: type,
      creator: authorEmail,
    );
  }

  Future<void> _showReviewDialog(NewsModel news) async {
    final bool? accepted = await AppPopups.choose<bool>(
      title: LocaleKeys.newsReview.tr,
      message: LocaleKeys.chooseActionForNews.tr,
      icon: Icons.rate_review_outlined,
      options: [
        if (news.status != NewsStates.publicado)
          PopupOption(
            value: true,
            label: LocaleKeys.accept.tr,
            icon: Icons.check_circle_outline_rounded,
            color: Colors.green.shade600,
          ),
        PopupOption(
          value: false,
          label: LocaleKeys.reject.tr,
          icon: Icons.cancel_outlined,
          color: Theme.of(Get.context!).colorScheme.error,
        ),
      ],
    );

    if (accepted == null) return;
    await _showReasonDialog(news, accepted);
  }

  Future<void> _showObservationDialog(String? observation) async {
    final text = (observation ?? '').trim();

    await AppPopups.alert(
      title: LocaleKeys.observations.tr,
      message: text.isEmpty ? LocaleKeys.noObservationAvailable.tr : text,
      icon: Icons.sticky_note_2_outlined,
      type: PopupType.warning,
      confirmText: LocaleKeys.close.tr,
    );
  }

  Future<void> _showReasonDialog(NewsModel news, bool accepted) async {
    final String? reason = await AppPopups.input(
      title: accepted
          ? LocaleKeys.reasonToAccept.tr
          : LocaleKeys.reasonToReject.tr,
      message: LocaleKeys.writeReason.tr,
      hint: LocaleKeys.writeReasonHere.tr,
      icon: accepted
          ? Icons.check_circle_outline_rounded
          : Icons.cancel_outlined,
      type: accepted ? PopupType.success : PopupType.error,
      confirmText: LocaleKeys.send.tr,
      maxLines: 4,
    );

    if (reason == null) return;

    await controller.reviewNews(
      newsId: news.id,
      isApproved: accepted,
      reason: reason,
      validator: controller.user.email!,
      creator: news.createdBy,
      validatorName: controller.user.name ?? '',
      newsType: news.type,
    );
  }

  String _getFormattedDate(String dataCriacao) {
    try {
      final creationDate = DateTime.parse(dataCriacao);
      final now = DateTime.now();
      final difference = now.difference(creationDate);

      if (difference.inSeconds < 60) {
        return LocaleKeys.secondsAgo
            .trParams({'count': '${difference.inSeconds}'});
      } else if (difference.inMinutes < 60) {
        return LocaleKeys.minutesAgo
            .trParams({'count': '${difference.inMinutes}'});
      } else if (difference.inHours < 24) {
        return LocaleKeys.hoursAgo
            .trParams({'count': '${difference.inHours}'});
      } else {
        return AppTranslation.formatDate(creationDate);
      }
    } catch (e) {
      return dataCriacao;
    }
  }

  Widget _buildSafeImage(String base64String, double height) {
    try {
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: height,
          color: Colors.grey[800],
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 40,
          ),
        ),
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        height: height,
        color: Colors.grey[800],
        child: const Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 40,
        ),
      );
    }
  }
}

// Uma ação do pop-up do banner da matéria
class _CardAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CardAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}