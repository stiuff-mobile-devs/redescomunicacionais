import 'package:flutter/material.dart';
import 'package:redescomunicacionais/app/services/device_detector_service.dart';

/// Classe utilitária para cálculos de responsividade
/// Centraliza todas as funções de responsividade para manter o código limpo
class ResponsiveUtils {
  static final DeviceDetectorService _deviceDetector =
      DeviceDetectorService.instance;

  // ===== MÉTODOS DE DETECÇÃO DE DISPOSITIVO =====

  /// Verifica se deve usar layout horizontal baseado no dispositivo e orientação
  static bool shouldUseHorizontalLayout(
      double screenWidth, double screenHeight) {
    final bool isPortrait = screenHeight > screenWidth;
    final bool isLandscape = !isPortrait;
    final bool isWeb = _deviceDetector.isWeb;

    return isWeb || (isLandscape && screenWidth > 700);
  }

  /// Detecta se é um tablet baseado na largura da tela
  static bool isTablet(double screenWidth) {
    return screenWidth > 600;
  }

  /// Detecta se é uma tela pequena
  static bool isSmallScreen(double screenWidth, double screenHeight) {
    return screenWidth < 400 || screenHeight < 600;
  }

  /// Detecta se está em modo portrait
  static bool isPortrait(double screenWidth, double screenHeight) {
    return screenHeight > screenWidth;
  }

  // ===== CÁLCULOS PARA LOGIN PAGE =====

  /// Calcula o tamanho da fonte do título na login page
  static double calculateLoginTitleSize(
      double screenWidth, bool isTablet, bool useHorizontalLayout) {
    if (useHorizontalLayout) {
      if (isTablet) return 36.0;
      return screenWidth < 800 ? 28.0 : 32.0;
    }

    if (isTablet) return 40.0;
    if (screenWidth < 350) return 22.0;
    if (screenWidth < 400) return 26.0;
    return 32.0;
  }

  /// Calcula o tamanho do logo na login page
  static double calculateLoginLogoSize(double screenWidth, double screenHeight,
      bool isPortrait, bool isTablet, bool useHorizontalLayout) {
    if (useHorizontalLayout) {
      if (isTablet) return screenHeight * 0.35;
      return screenHeight * 0.3;
    }

    if (isTablet) return screenWidth * 0.25;

    double baseSize = isPortrait ? screenWidth * 0.4 : screenHeight * 0.3;

    // Limitadores para diferentes tamanhos de tela
    if (screenWidth < 350) return baseSize.clamp(120.0, 160.0);
    if (screenWidth < 400) return baseSize.clamp(140.0, 180.0);

    return baseSize.clamp(160.0, 220.0);
  }

  /// Calcula a largura dos botões na login page
  static double calculateLoginButtonWidth(
      double screenWidth, bool isTablet, bool useHorizontalLayout) {
    if (useHorizontalLayout) {
      if (isTablet) return screenWidth * 0.25;
      return screenWidth * 0.3;
    }

    if (isTablet) return screenWidth * 0.4;
    if (screenWidth < 350) return screenWidth * 0.85;
    if (screenWidth < 400) return screenWidth * 0.8;
    return screenWidth * 0.75;
  }

  /// Calcula o padding da tela na login page
  static EdgeInsets calculateLoginScreenPadding(double screenWidth,
      double screenHeight, bool isTablet, bool useHorizontalLayout) {
    if (useHorizontalLayout) {
      double horizontal = isTablet ? screenWidth * 0.08 : screenWidth * 0.05;
      double vertical = isTablet ? screenHeight * 0.04 : screenHeight * 0.02;

      return EdgeInsets.symmetric(
        horizontal: horizontal.clamp(20.0, 80.0),
        vertical: vertical.clamp(16.0, 40.0),
      );
    }

    double horizontal = isTablet ? screenWidth * 0.1 : screenWidth * 0.05;
    double vertical = isTablet ? screenHeight * 0.05 : screenHeight * 0.02;

    return EdgeInsets.symmetric(
      horizontal: horizontal.clamp(16.0, 60.0),
      vertical: vertical.clamp(8.0, 30.0),
    );
  }

  /// Calcula o espaçamento vertical na login page
  static double calculateLoginVerticalSpacing(
      double screenHeight, bool isPortrait, bool isSmallScreen) {
    if (isSmallScreen) return screenHeight * 0.035;
    if (!isPortrait) return screenHeight * 0.045;
    return screenHeight * 0.04;
  }

  // ===== CÁLCULOS PARA HOME PAGE =====

  /// Calcula o tamanho da fonte do título do AppBar
  static double calculateAppBarTitleSize(
      double screenWidth, bool isTablet, bool useHorizontalLayout) {
    if (useHorizontalLayout) {
      if (isTablet) return 24.0;
      return screenWidth < 800 ? 18.0 : 20.0;
    }

    if (isTablet) return 22.0;
    if (screenWidth < 350) return 16.0;
    if (screenWidth < 400) return 18.0;
    return 20.0;
  }

  /// Calcula o tamanho dos ícones
  static double calculateIconSize(double screenWidth, bool isTablet) {
    if (isTablet) return 28.0;
    if (screenWidth < 350) return 20.0;
    return 24.0;
  }

  /// Calcula a altura da bottom navigation bar
  static double calculateBottomBarHeight(double screenHeight, bool isTablet) {
    if (isTablet) return 50.0;
    if (screenHeight < 600) return 35.0;
    return 40.0;
  }

  /// Calcula o tamanho da fonte da bottom navigation bar
  static double calculateBottomBarFontSize(double screenWidth, bool isTablet) {
    if (isTablet) return 20.0;
    if (screenWidth < 350) return 14.0;
    if (screenWidth < 400) return 16.0;
    return 18.0;
  }

  // ===== CÁLCULOS UNIVERSAIS =====

  /// Calcula o tamanho da fonte para versão/footer
  static double calculateVersionFontSize(double screenWidth, bool isTablet) {
    if (isTablet) return 14.0;
    if (screenWidth < 350) return 9.0;
    return 10.0;
  }

  /// Calcula padding responsivo baseado no tamanho da tela
  static EdgeInsets calculateResponsivePadding(
      double screenWidth, double screenHeight, bool isTablet) {
    double horizontal = isTablet ? screenWidth * 0.05 : screenWidth * 0.03;
    double vertical = isTablet ? screenHeight * 0.03 : screenHeight * 0.02;

    return EdgeInsets.symmetric(
      horizontal: horizontal.clamp(12.0, 40.0),
      vertical: vertical.clamp(8.0, 24.0),
    );
  }

  /// Calcula margem responsiva
  static EdgeInsets calculateResponsiveMargin(
      double screenWidth, double screenHeight, bool isTablet) {
    double horizontal = isTablet ? screenWidth * 0.03 : screenWidth * 0.02;
    double vertical = isTablet ? screenHeight * 0.02 : screenHeight * 0.015;

    return EdgeInsets.symmetric(
      horizontal: horizontal.clamp(8.0, 24.0),
      vertical: vertical.clamp(4.0, 16.0),
    );
  }

  /// Calcula border radius responsivo
  static double calculateResponsiveBorderRadius(bool isTablet) {
    return isTablet ? 16.0 : 12.0;
  }

  /// Calcula elevação responsiva
  static double calculateResponsiveElevation(bool isTablet) {
    return isTablet ? 8.0 : 4.0;
  }

  // ===== WIDGETS HELPER =====

  /// Cria um diálogo responsivo com tema padrão
  static AlertDialog createResponsiveDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
    String confirmText = "OK",
    String? cancelText,
    VoidCallback? onCancel,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = ResponsiveUtils.isTablet(screenWidth);

    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(calculateResponsiveBorderRadius(isTablet)),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 22.0 : 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          color: Colors.white70,
          fontSize: isTablet ? 16.0 : 14.0,
        ),
      ),
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24.0 : 16.0,
                vertical: isTablet ? 12.0 : 8.0,
              ),
            ),
            child: Text(
              cancelText,
              style: TextStyle(
                color: Colors.grey,
                fontSize: isTablet ? 16.0 : 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24.0 : 16.0,
              vertical: isTablet ? 12.0 : 8.0,
            ),
          ),
          child: Text(
            confirmText,
            style: TextStyle(
              color: Colors.blue,
              fontSize: isTablet ? 16.0 : 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Cria um texto responsivo com estilo padrão
  static Widget createResponsiveText(
    String text, {
    required double screenWidth,
    bool isTablet = false,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.left,
    int maxLines = 1,
    bool useCustomSize = false,
    double? customSize,
  }) {
    double fontSize;

    if (useCustomSize && customSize != null) {
      fontSize = customSize;
    } else {
      if (isTablet) {
        fontSize = 16.0;
      } else if (screenWidth < 350) {
        fontSize = 12.0;
      } else if (screenWidth < 400) {
        fontSize = 14.0;
      } else {
        fontSize = 16.0;
      }
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
        ),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
