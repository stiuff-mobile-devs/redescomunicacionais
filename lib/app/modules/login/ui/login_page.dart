import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/login/controller/login_controller.dart';
import 'package:redescomunicacionais/app/controller/version_controller.dart';
import 'package:redescomunicacionais/app/services/device_detector_service.dart';
import 'package:redescomunicacionais/app/utils/responsive_utils.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _loginController = Get.find<LoginController>();
  final versionController = Get.find<VersionController>();
  final DeviceDetectorService deviceDetector = DeviceDetectorService.instance;

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blue,
              Colors.black,
            ],
          ),
        ),
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
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: Row(
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
                        vertical: verticalSpacing * 0.8,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Redes Comunicacionais\nLocais",
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

                    SizedBox(height: verticalSpacing * 1.0),

                    // Logo
                    SvgPicture.asset(
                      'assets/RCLLogo.svg',
                      width: logoSize,
                      height: logoSize,
                      // ignore: deprecated_member_use
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: verticalSpacing * 1.2),

                    // Versão
                    Text(
                      versionController.version,
                      style: TextStyle(
                        fontSize: versionFontSize,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Botão Google
                    Container(
                      width: buttonWidth,
                      margin: EdgeInsets.symmetric(
                        vertical: verticalSpacing * 0.6,
                      ),
                      child: SignInButton(
                        Buttons.google,
                        text: 'Entrar com Google',
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 20.0 : 18.0,
                          horizontal: 20.0,
                        ),
                        onPressed: _loginController.loginGoogle,
                      ),
                    ),

                    SizedBox(height: verticalSpacing * 0.4),

                    // Botão Microsoft
                    Container(
                      width: buttonWidth,
                      margin: EdgeInsets.symmetric(
                        vertical: verticalSpacing * 0.6,
                      ),
                      child: SignInButton(
                        Buttons.microsoft,
                        text: 'Entrar com Microsoft',
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 24.0 : 22.0,
                          horizontal: 20.0,
                        ),
                        onPressed: _loginController.loginMicrosoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título responsivo
              Flexible(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: verticalSpacing * 0.8,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Redes Comunicacionais Locais",
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
              Flexible(
                flex: 3,
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: verticalSpacing * 0.6),
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

              // Botões de login responsivos
              Flexible(
                flex: 3,
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão Google
                      Container(
                        width: buttonWidth,
                        margin: EdgeInsets.symmetric(
                          vertical: verticalSpacing * 0.4,
                        ),
                        child: SignInButton(
                          Buttons.google,
                          text: 'Entrar com Google',
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 20.0 : 16.0,
                            horizontal: 16.0,
                          ),
                          onPressed: _loginController.loginGoogle,
                        ),
                      ),

                      SizedBox(height: verticalSpacing * 0.3),

                      // Botão Microsoft
                      Container(
                        width: buttonWidth,
                        margin: EdgeInsets.symmetric(
                          vertical: verticalSpacing * 0.4,
                        ),
                        child: SignInButton(
                          Buttons.microsoft,
                          text: 'Entrar com Microsoft',
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 24.0 : 22.0,
                            horizontal: 16.0,
                          ),
                          onPressed: _loginController.loginMicrosoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Versão responsiva
              Flexible(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: verticalSpacing * 0.6,
                      bottom: verticalSpacing * 0.4,
                    ),
                    child: Text(
                      versionController.version,
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
            ],
          ),
        ),
      ),
    );
  }
}
