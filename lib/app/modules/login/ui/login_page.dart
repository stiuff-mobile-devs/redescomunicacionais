import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/login/controller/login_controller.dart';
import 'package:redescomunicacionais/app/utils/responsive_utils.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final bool isPortrait =
        ResponsiveUtils.isPortrait(screenWidth, screenHeight);
    final bool isSmallScreen =
        ResponsiveUtils.isSmallScreen(screenWidth, screenHeight);
    final bool isTablet = ResponsiveUtils.isTablet(screenWidth);
    final bool useHorizontalLayout =
        ResponsiveUtils.shouldUseHorizontalLayout(screenWidth, screenHeight);

    // Calcula tamanhos responsivos usando a classe utilitária
    double titleFontSize = ResponsiveUtils.calculateLoginTitleSize(
        screenWidth, isTablet, useHorizontalLayout);
    double logoSize = ResponsiveUtils.calculateLoginLogoSize(
        screenWidth, screenHeight, isPortrait, isTablet, useHorizontalLayout);
    double buttonWidth = ResponsiveUtils.calculateLoginButtonWidth(
        screenWidth, isTablet, useHorizontalLayout);
    double versionFontSize =
        ResponsiveUtils.calculateVersionFontSize(screenWidth, isTablet);

    // Calcula paddings responsivos usando a classe utilitária
    EdgeInsets screenPadding = ResponsiveUtils.calculateLoginScreenPadding(
        screenWidth, screenHeight, isTablet, useHorizontalLayout);
    double verticalSpacing = ResponsiveUtils.calculateLoginVerticalSpacing(
        screenHeight, isPortrait, isSmallScreen);

    return Scaffold(
      body: Container(
        decoration:
            BoxDecoration(gradient: AppColors.darkBlueToBlackGradient()),
        child: SafeArea(
          child: Padding(
            padding: screenPadding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (useHorizontalLayout) {
                  return _buildHorizontalLayout(
                    constraints,
                    titleFontSize,
                    logoSize,
                    buttonWidth,
                    versionFontSize,
                    verticalSpacing,
                    screenWidth,
                    isTablet,
                  );
                } else {
                  return _buildVerticalLayout(
                    constraints,
                    titleFontSize,
                    logoSize,
                    buttonWidth,
                    versionFontSize,
                    verticalSpacing,
                    screenWidth,
                    isSmallScreen,
                    isTablet,
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  // Layout horizontal para web e landscape
  Widget _buildHorizontalLayout(
    BoxConstraints constraints,
    double titleFontSize,
    double logoSize,
    double buttonWidth,
    double versionFontSize,
    double verticalSpacing,
    double screenWidth,
    bool isTablet,
  ) {
    return Row(
      children: [
        // Lado esquerdo - Logo e título
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: verticalSpacing,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: verticalSpacing * 0.5,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'app_name_multiline'.tr,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),

                SizedBox(height: verticalSpacing * 0.6),

                // Logo
                Flexible(
                  child: SvgPicture.asset(
                    'assets/RCLLogo.svg',
                    width: logoSize,
                    height: logoSize,
                    // ignore: deprecated_member_use
                    color: Colors.white,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: verticalSpacing * 0.8),

                // Versão
                Obx(
                  () => Text(
                    '${'version_label'.tr}: ${controller.appVersion.value}',
                    style: TextStyle(
                      fontSize: versionFontSize,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lado direito - Botões de login
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: verticalSpacing,
            ),
            child: LayoutBuilder(
              builder: (context, buttonConstraints) {
                return _buildLoginButtonsGrid(
                  maxWidth: buttonConstraints.maxWidth,
                  maxHeight: buttonConstraints.maxHeight,
                  targetButtonWidth: buttonWidth,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Layout vertical para mobile portrait
  Widget _buildVerticalLayout(
    BoxConstraints constraints,
    double titleFontSize,
    double logoSize,
    double buttonWidth,
    double versionFontSize,
    double verticalSpacing,
    double screenWidth,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Título responsivo
        Expanded(
          flex: 2,
          child: Container(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: verticalSpacing * 0.5,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'app_name_full'.tr,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: isSmallScreen ? 2 : 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ),
        ),

        // Logo responsivo
        Expanded(
          flex: 2,
          child: Container(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: verticalSpacing * 0.4),
              child: SvgPicture.asset(
                'assets/RCLLogo.svg',
                width: logoSize,
                height: logoSize,
                // ignore: deprecated_member_use
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // Botões de login em grade 2x2
        Expanded(
          flex: 3,
          child: Container(
            alignment: Alignment.center,
            child: LayoutBuilder(
              builder: (context, buttonConstraints) {
                return _buildLoginButtonsGrid(
                  maxWidth: buttonConstraints.maxWidth,
                  maxHeight: buttonConstraints.maxHeight,
                  targetButtonWidth: buttonWidth,
                );
              },
            ),
          ),
        ),

        // Versão responsiva
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(
                top: verticalSpacing * 0.3,
                bottom: verticalSpacing * 0.2,
              ),
              child: Obx(
                () => Text(
                  '${'version_label'.tr}: ${controller.appVersion.value}',
                  style: TextStyle(
                    fontSize: versionFontSize,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButtonsGrid({
    required double maxWidth,
    required double maxHeight,
    required double targetButtonWidth,
  }) {
    const double gap = 10.0;
    final double availableWidth = (maxWidth - gap).clamp(0.0, double.infinity);
    final double gridButtonWidth =
        (availableWidth / 2).clamp(120.0, targetButtonWidth);
    final double availableHeight =
        (maxHeight - gap).clamp(0.0, double.infinity);
    final double gridButtonHeight = (availableHeight / 2).clamp(84.0, 140.0);

    return Center(
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        alignment: WrapAlignment.center,
        children: [
          _buildLoginCardButton(
            label: 'login_with_google'.tr,
            iconData: FontAwesomeIcons.google,
            badgeColor: Colors.white,
            iconColor: const Color(0xFFEA4335),
            onPressed: controller.loginGoogle,
            width: gridButtonWidth,
            height: gridButtonHeight,
          ),
          _buildLoginCardButton(
            label: 'login_with_microsoft'.tr,
            iconData: FontAwesomeIcons.microsoft,
            badgeColor: Colors.white,
            iconColor: const Color(0xFF00A4EF),
            onPressed: controller.loginMicrosoft,
            width: gridButtonWidth,
            height: gridButtonHeight,
          ),
          _buildLoginCardButton(
            label: 'login_with_apple'.tr,
            badgeColor: Colors.white,
            iconData: FontAwesomeIcons.apple,
            iconColor: Colors.black,
            onPressed: controller.loginApple,
            width: gridButtonWidth,
            height: gridButtonHeight,
          ),
          _buildLoginCardButton(
            label: 'login_anonymously'.tr,
            badgeColor: Colors.white,
            iconData: FontAwesomeIcons.userSecret,
            iconColor: Colors.black,
            onPressed: controller.loginAnonymous,
            width: gridButtonWidth,
            height: gridButtonHeight,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCardButton({
    required String label,
    required Color badgeColor,
    required FaIconData iconData,
    required Color iconColor,
    required VoidCallback onPressed,
    required double width,
    required double height,
  }) {
    final bool compact = width < 170;
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.22),
                width: 1.0,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8.0 : 12.0,
              vertical: compact ? 8.0 : 10.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: compact ? 30.0 : 34.0,
                  height: compact ? 30.0 : 34.0,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    iconData,
                    size: compact ? 14.0 : 16.0,
                    color: iconColor,
                  ),
                ),
                SizedBox(height: compact ? 6.0 : 8.0),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 11.0 : 12.5,
                    height: 1.2,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
