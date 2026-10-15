
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:redescomunicacionais/app/modules/login/controller/login_controller.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/services/release_notes_service.dart';
import 'package:redescomunicacionais/app/services/update_version_service.dart';

class SplashController extends GetxController {
  late final LoginController _loginController;

  final UpdateVersionService _updateService = UpdateVersionService();
  final ReleaseNotesService _releaseNotesService = ReleaseNotesService();
  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loginController = Get.find<LoginController>();
  }

  @override
  void onReady() {
    super.onReady();
    _checkAppUpdate();
  }

  Future<void> _checkAppUpdate() async {
    await _updateService.initialize();

    try {
      if (Get.context != null) {
        await _updateService.checkForUpdates(Get.context!);
      }
    } catch (e) {
      debugPrint('Erro ao verificar atualização: $e');
    }

    await _checkReleaseNotes();
    _checkWelcome();
  }

  Future<void> _checkReleaseNotes() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      final storageKey = 'release_notes_seen_$version';

      debugPrint('Versão instalada: $version');

      final bool alreadySeen = _storage.read(storageKey) ?? false;

      if (alreadySeen) {
        debugPrint(
          'Novidades já exibidas para a versão $version.',
        );
        return;
      }

      final notesData =
      await _releaseNotesService.getReleaseNotes(version);

      if (notesData == null) {
        debugPrint(
          'Nenhuma novidade ativa encontrada para a versão $version.',
        );
        return;
      }

      final notes = notesData['releaseNotes'] as List<String>;

      if (notes.isEmpty) {
        debugPrint('A lista de novidades está vazia.');
        return;
      }

      if (Get.context == null) {
        debugPrint('Contexto do aplicativo indisponível.');
        return;
      }

      debugPrint('Exibindo novidades da versão $version.');

      await Get.dialog<void>(
        AlertDialog(
          title: Text(
            notesData['title'] as String? ??
                'Novidades da atualização',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: notes.map((note) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(
                        child: Text(note),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back<void>(),
              child: const Text('Entendi'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      await _storage.write(storageKey, true);

      debugPrint('Novidades marcadas como exibidas.');
    } catch (e, stackTrace) {
      debugPrint(
        'Erro ao exibir novidades da atualização: $e',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _checkWelcome() {
    final bool welcomeSeen = _storage.read('welcome_seen') ?? false;

    if (!welcomeSeen) {
      Get.offNamed(Routes.WELCOME);
      return;
    }

    _loginController.tryLogin();
  }
}
