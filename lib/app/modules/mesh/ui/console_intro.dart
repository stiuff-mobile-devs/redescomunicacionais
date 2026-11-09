import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/mesh/console_page.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

// Aviso mostrado antes de abrir o Console Mesh (aberto pelo menu lateral).
// Explica em linguagem simples o que é a ferramenta de testes da rede mesh.
class MeshConsoleIntro {
  MeshConsoleIntro._();

  static Future<void> open() async {
    final bool? openConsole = await AppPopups.sheet<bool>(
      title: LocaleKeys.meshConsoleIntroTitle.tr,
      message: LocaleKeys.meshConsoleIntroMessage.tr,
      icon: Icons.hub_rounded,
      child: Column(
        children: [
          _Topic(
            icon: Icons.share_rounded,
            color: Colors.lightBlue,
            text: LocaleKeys.meshConsoleIntroShare.tr,
          ),
          const SizedBox(height: 12),
          _Topic(
            icon: Icons.radar_rounded,
            color: Colors.green,
            text: LocaleKeys.meshConsoleIntroRadar.tr,
          ),
          const SizedBox(height: 12),
          _Topic(
            icon: Icons.science_outlined,
            color: Colors.amber.shade700,
            text: LocaleKeys.meshConsoleIntroSafe.tr,
          ),
        ],
      ),
      actions: (ctx) => [
        AppSheetButton.primary(
          label: LocaleKeys.openConsole.tr,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
        AppSheetButton.secondary(
          label: LocaleKeys.notNow.tr,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
      ],
    );

    if (openConsole == true) {
      Get.to(() => const ConsolePage());
    }
  }
}

// Um tópico do aviso: ícone colorido num círculo + texto
class _Topic extends StatelessWidget {
  const _Topic({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
