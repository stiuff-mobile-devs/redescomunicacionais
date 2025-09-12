import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/controller/version_controller.dart';
import 'package:redescomunicacionais/app/routes/app_pages.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/services/hive_service.dart';
import 'package:redescomunicacionais/app/utils/theme/app_theme.dart';
import 'package:redescomunicacionais/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await HiveInitializer
      .initialize(); // Inicializa o Hive e registra os adapters

  Get.put(VersionController());
  runApp(
    GetMaterialApp(
      title: 'Redes Comunicacionais',
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
      initialRoute: Routes.INITIAL,
      theme: appThemeData,
      // ADICIONE ESTAS LINHAS AQUI:
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
    ),
  );
}
