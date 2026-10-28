import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:intl/intl.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/utils/widgets/blinking_loading_icon.dart';
import 'package:redescomunicacionais/app/utils/theme/theme_controller.dart';

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
              'no_news_available'.tr,
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
          bool isSelected = controller.isSelected(index);

          return Column(
            children: [
              if (isSelected)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      if (controller.canEdit(news))
                        GestureDetector(
                          onTap: () {
                            controller.openEditNews(news);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: theme.colorScheme.onSurface,
                                  size: 30,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'edit'.tr,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (controller.canDelete(news))
                        GestureDetector(
                          onTap: () {
                            _hideNewsPopup(news.id, controller.user.email!,
                                news.createdBy, news.type);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'delete'.tr,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (controller.canReReview(news))
                        GestureDetector(
                          onTap: () => _showReviewDialog(news),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.rate_review,
                                  color: Colors.yellowAccent,
                                  size: 30,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'review'.tr,
                                  style: const TextStyle(
                                    color: Colors.yellowAccent,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (controller.homeController.isRejectedMode.value)
                        GestureDetector(
                          onTap: () => _showObservationDialog(
                            news.rejectedObservation,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.sticky_note_2_outlined,
                                  color: Colors.orangeAccent,
                                  size: 30,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'observations'.tr,
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              GestureDetector(
                onTap: () => controller.openNews(news),
                onLongPress: () => controller.toggleSelected(index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: isSelected
                          ? Radius.zero
                          : const Radius.circular(12.0),
                      topRight: isSelected
                          ? Radius.zero
                          : const Radius.circular(12.0),
                      bottomLeft: const Radius.circular(12.0),

                    ),
                    border: isSelected
                        ? Border.all(
                      color: theme.colorScheme.primary,
                      width: 2.0,
                    )
                        : null,
                  ),
                  margin: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 8.0,
                    top: isSelected ? 0.0 : 8.0,
                  ),
                  child: Card(
                    color: theme.colorScheme.surface,
                    margin: EdgeInsets.zero,
                    elevation: isSelected ? 8.0 : 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: isSelected
                            ? Radius.zero
                            : const Radius.circular(12.0),
                        topRight: isSelected
                            ? Radius.zero
                            : const Radius.circular(12.0),
                        bottomLeft: const Radius.circular(12.0),
                        bottomRight: const Radius.circular(12.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: isSelected
                                ? Radius.zero
                                : const Radius.circular(12.0),
                            topRight: isSelected
                                ? Radius.zero
                                : const Radius.circular(12.0),
                          ),
                          child: news.urlImages.isNotEmpty &&
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
              ),
            ],
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
              'Carregar mais Matérias'.tr,
              style: theme.textTheme.bodyLarge,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _hideNewsPopup(
      String newsId, String userEmail, String authorEmail, String type) async {
    final theme = Theme.of(Get.context!);

    await Get.dialog(
      AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          '${'delete'.tr} $type',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          '${'confirm_delete_this'.tr} $type?',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.hideNews(
                newsId: newsId,
                status: NewsStates.deletado,
                userEmail: userEmail,
                type: type,
                creator: authorEmail,
              );
            },
            child: const Text(
              'delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _showReviewDialog(NewsModel news) async {
    final theme = Theme.of(Get.context!);

    await Get.dialog(
      AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'news_review'.tr,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'choose_action_for_news'.tr,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          if (news.status != NewsStates.publicado)
            TextButton(
              onPressed: () async {
                Get.back();
                await _showReasonDialog(news, true);
              },
              child: const Text(
                'accept',
                style: TextStyle(color: Colors.green),
              ),
            ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _showReasonDialog(news, false);
            },
            child: const Text(
              'reject',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _showObservationDialog(String? observation) async {
    final text = (observation ?? '').trim();
    final theme = Theme.of(Get.context!);

    await Get.dialog(
      AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'observations'.tr,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          text.isEmpty ? 'no_observation_available'.tr : text,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'close'.tr,
              style: TextStyle(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _showReasonDialog(NewsModel news, bool accepted) async {
    final TextEditingController reasonController = TextEditingController();
    final theme = Theme.of(Get.context!);

    await Get.dialog(
      AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          accepted ? 'reason_to_accept'.tr : 'reason_to_reject'.tr,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'write_reason'.tr,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: reasonController,
              maxLines: 4,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'write_reason_here'.tr,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonController.text.trim();

              Get.back();

              await controller.reviewNews(
                newsId: news.id,
                isApproved: accepted,
                reason: reason,
                validator: controller.user.email!,
                creator: news.createdBy,
                validatorName: controller.user.name ?? '',
                newsType: news.type,
              );
            },
            child: Text(
              'send'.tr,
              style: TextStyle(
                color: accepted ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  String _getFormattedDate(String dataCriacao) {
    try {
      final creationDate = DateTime.parse(dataCriacao);
      final now = DateTime.now();
      final difference = now.difference(creationDate);

      if (difference.inSeconds < 60) {
        return '${difference.inSeconds} ${'seconds_ago'.tr}';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} ${'minutes_ago'.tr}';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} ${'hours_ago'.tr}';
      } else {
        return DateFormat('dd/MM/yyyy').format(creationDate);
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