import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/central_de_comunicacao/controller/cdc_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:redescomunicacionais/app/modules/utils/widgets/blinking_loading_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/theme_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_bars.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_tones.dart';

class CentralDeComunicacaoPage extends GetView<CentralDeComunicacaoController> {
  const CentralDeComunicacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();
    final bool isLight = themeController.isLight;

    return Scaffold(
      appBar: AppBars.build(
        title: LocaleKeys.communicationCenter.tr,
        tone: AppTone.info,
      ),

      body: Obx(
            () => controller.isBusy.value
            ? Center(
          child: BlinkingLoadingIcon(
            size: 36,
            color: theme.colorScheme.primary,
          ),
        )
            : Container(
          decoration: isLight
              ? BoxDecoration(
            color: theme.scaffoldBackgroundColor,
          )
              : BoxDecoration(
            gradient: AppColors.darkBlueToBlackGradient(),
          ),

          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                ),
                child: Text(
                  LocaleKeys.chats.tr,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: GridView.builder(
                  itemCount: controller.chats.length,

                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),

                  itemBuilder: (context, index) {
                    final chat = controller.chats[index];

                    return GestureDetector(
                      onTap: () async {
                        final url = chat['url']!;

                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          AppPopups.error(LocaleKeys.couldNotOpenChat.tr);
                        }
                      },

                      child: Container(
                        decoration: BoxDecoration(
                          color: isLight
                              ? theme.colorScheme.surface
                              : Colors.white.withOpacity(0.1),

                          borderRadius:
                          BorderRadius.circular(16),

                          border: Border.all(
                            color: isLight
                                ? theme.colorScheme.outlineVariant
                                : Colors.white24,
                          ),
                        ),

                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,

                          children: [
                            CircleAvatar(
                              backgroundImage:
                              AssetImage(chat['image']!),
                              radius: 32,
                            ),

                            const SizedBox(height: 12),

                            Text(
                              chat['name']!,
                              style: TextStyle(
                                color:
                                theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
