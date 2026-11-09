import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/connections/controller/connections_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/theme_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_bars.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_tones.dart';

class ConnectionsPage extends GetView<ConnectionsController> {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLight = Get.find<ThemeController>().isLight;

    return Scaffold(
      backgroundColor: isLight ? theme.scaffoldBackgroundColor : null,

      appBar: AppBars.build(
        title: LocaleKeys.connections.tr,
        tone: AppTone.info,
      ),

      body: Obx(
            () => Container(
          width: double.infinity,
          height: double.infinity,
          // Mesmo fundo das outras telas: liso no claro, degradê no escuro
          decoration: isLight
              ? BoxDecoration(color: theme.scaffoldBackgroundColor)
              : BoxDecoration(gradient: AppColors.darkBlueToBlackGradient()),

          child: controller.isLoading.value
              ? Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          )
              : _buildConnectionsContent(context),
        ),
      ),
    );
  }

  Widget _buildConnectionsContent(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          24,
        ),
        children: [
          _buildConnectionsHeader(context),

          const SizedBox(height: 16),

          _buildInternetConnectionCard(context),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Fundo e borda dos cards: superfície no claro, vidro translúcido no escuro
  // (mesmo estilo dos cards da central da matéria)
  BoxDecoration _cardDecoration(
    BuildContext context, {
    required double radius,
    Color? borderColor,
    double borderWidth = 1,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final bool isLight = Get.find<ThemeController>().isLight;

    return BoxDecoration(
      color: isLight ? scheme.surface : Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ??
            (isLight
                ? scheme.outlineVariant
                : Colors.white.withValues(alpha: 0.14)),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.20),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildConnectionsHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: _cardDecoration(context, radius: 14),
      child: Text(
        LocaleKeys.connectionsDescription.tr,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInternetConnectionCard(BuildContext context) {
    return Obx(
          () => _buildConnectionCard(
        context: context,
        title: LocaleKeys.internet.tr,
        description: LocaleKeys.internetDescription.tr,
        icon: Icons.wifi_rounded,
        accentColor: Colors.cyan.shade700,
        isConnected: controller.isInternetConnected.value,
      ),
    );
  }

  Widget _buildConnectionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required bool isConnected,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(
        context,
        radius: 16,
        borderColor: accentColor.withValues(alpha: 0.55),
        borderWidth: 1.2,
      ),

      child: Row(
        children: [
          // Ícone
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 26,
            ),
          ),

          const SizedBox(width: 12),

          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Status
          _buildStatusBadge(
            isConnected: isConnected,
            accentColor: accentColor,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required bool isConnected,
    required Color accentColor,
    required BuildContext context,
  }) {
    final Color badgeColor =
    isConnected ? Colors.green.shade600 : Colors.red.shade600;

    final String label = isConnected
        ? LocaleKeys.statusActive.tr
        : LocaleKeys.statusFailed.tr;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),

        border: Border.all(
          color: badgeColor.withValues(alpha: 0.45),
          width: 1,
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 6),

          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}