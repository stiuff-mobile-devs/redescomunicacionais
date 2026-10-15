import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redescomunicacionais/app/routes/app_pages.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/services/hive_service.dart';
import 'package:redescomunicacionais/app/utils/theme/app_theme.dart';
import 'package:redescomunicacionais/app/utils/theme/theme_controller.dart';
import 'package:redescomunicacionais/app/utils/translations/app_translations.dart';
import 'package:redescomunicacionais/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa o armazenamento local do GetStorage
  await GetStorage.init();

  // Inicializa o Hive
  await HiveInitializer.initialize();

  // Registra o controlador de tema
  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
          () => GetMaterialApp(
        title: 'Redes Comunicacionais',
        debugShowCheckedModeBanner: true,

        getPages: AppPages.routes,
        initialRoute: Routes.INITIAL,

        // Tema claro
        theme: appThemeDataLight,

        // Tema clássico/escuro
        darkTheme: appThemeDataClassic,

        // Tema atualmente selecionado pelo usuário
        themeMode: themeController.themeMode.value,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],

        translations: AppTranslation(),
        supportedLocales: AppTranslation.supportedLocales,
        locale: AppTranslation.normalizeLocale(
          Get.deviceLocale,
        ),
        fallbackLocale: AppTranslation.fallback,
      ),
    );
  }
}