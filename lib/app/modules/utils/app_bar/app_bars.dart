import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_tones.dart';
import 'package:redescomunicacionais/app/modules/utils/responsive_utils.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

// Ponto único para as AppBars do app (mesmo espírito do AppPopups).
//
// Todas as telas usam o mesmo padrão: degradê do azul da marca até a cor do
// tom da tela (AppTone), nos temas claro e escuro, com a cor do texto e dos
// ícones calculada automaticamente para manter o contraste.
//
// Nunca monte AppBar(...) direto nas telas.
class AppBars {
  AppBars._();

  static const Duration toneAnimation = Duration(milliseconds: 350);

  static PreferredSizeWidget build({
    String? title,
    Widget? titleWidget,
    AppTone tone = AppTone.brand,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    PreferredSizeWidget? bottom,
    bool centerTitle = true,
  }) {
    assert(title != null || titleWidget != null);
    final bool isTablet = ResponsiveUtils.isTablet(Get.width);

    return _GradientAppBar(
      title: title,
      titleWidget: titleWidget,
      tone: tone,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      centerTitle: centerTitle,
      isTablet: isTablet,
      toolbarHeight: isTablet ? 64.0 : 56.0,
    );
  }

  // Cores do degradê para o tom e o tema atuais.
  static List<Color> gradientColors(AppTone tone, Brightness brightness) {
    if (brightness == Brightness.dark) {
      final start = AppColors.darkBlue();
      return [start, Color.lerp(start, tone.color, 0.55)!];
    }
    final start = AppColors.alternativeMediumBlue();
    return [start, Color.lerp(start, tone.color, 0.7)!];
  }

  // Cor de texto/ícones legível sobre o degradê.
  static Color foregroundColor(AppTone tone, Brightness brightness) {
    final colors = gradientColors(tone, brightness);
    final middle = Color.lerp(colors.first, colors.last, 0.5)!;
    return ThemeData.estimateBrightnessForColor(middle) == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }
}

class _GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _GradientAppBar({
    required this.title,
    required this.titleWidget,
    required this.tone,
    required this.actions,
    required this.leading,
    required this.automaticallyImplyLeading,
    required this.bottom,
    required this.centerTitle,
    required this.isTablet,
    required this.toolbarHeight,
  });

  final String? title;
  final Widget? titleWidget;
  final AppTone tone;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final bool isTablet;
  final double toolbarHeight;

  static const double _radius = 16;

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = AppBars.gradientColors(tone, brightness);
    final foreground = AppBars.foregroundColor(tone, brightness);
    final screenWidth = MediaQuery.of(context).size.width;

    final titleSize = ResponsiveUtils.calculateAppBarTitleSize(
            screenWidth, isTablet, false)
        .clamp(16.0, 22.0);
    final iconSize =
        ResponsiveUtils.calculateIconSize(screenWidth, isTablet).clamp(20.0, 28.0);

    return AppBar(
      title: titleWidget ??
          Text(
            title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      titleTextStyle: TextStyle(
        color: foreground,
        fontSize: titleSize,
        fontWeight: FontWeight.w600,
      ),
      centerTitle: centerTitle,
      leading: leading ?? _defaultLeading(context, iconSize),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
      foregroundColor: foreground,
      iconTheme: IconThemeData(color: foreground, size: iconSize),
      actionsIconTheme: IconThemeData(color: foreground, size: iconSize),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      scrolledUnderElevation: 3,
      shadowColor: Colors.black54,
      systemOverlayStyle: foreground == Colors.white
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(_radius)),
      ),
      // AnimatedContainer: a troca de tom (ex.: filtros da central) fica suave
      flexibleSpace: AnimatedContainer(
        duration: AppBars.toneAnimation,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  // Seta de voltar padronizada. Se a tela tem menu lateral, deixa o AppBar
  // mostrar o ícone do menu.
  Widget? _defaultLeading(BuildContext context, double iconSize) {
    if (!automaticallyImplyLeading) return null;
    if (Scaffold.maybeOf(context)?.hasDrawer ?? false) return null;
    if (!(ModalRoute.of(context)?.canPop ?? false)) return null;

    return IconButton(
      tooltip: LocaleKeys.back.tr,
      icon: Icon(Icons.arrow_back_rounded, size: iconSize),
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}
