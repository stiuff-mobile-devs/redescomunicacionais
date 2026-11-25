
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/app_translations.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:url_launcher/url_launcher.dart';

enum UpdateStatus {
  upToDate,
  optionalUpdate,
  forceUpdate,
}

class UpdateVersionService {
  final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Erro ao inicializar Remote Config: $e');
    }
  }

  Future<void> checkForUpdates(BuildContext context) async {
    if (Platform.isAndroid) {
      await _handleAndroidUpdate(context);
    } else if (Platform.isIOS) {
      await _handleIOSUpdate(context);
    }
  }

  Future<void> _handleAndroidUpdate(BuildContext context) async {
    try {
      final AppUpdateInfo updateInfo =
      await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability !=
          UpdateAvailability.updateAvailable) {
        return;
      }

      final UpdateStatus status =
      await _checkFirebaseVersionStatus();

      if (status == UpdateStatus.forceUpdate &&
          updateInfo.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
      } else if (status == UpdateStatus.optionalUpdate &&
          updateInfo.flexibleUpdateAllowed) {
        final AppUpdateResult result =
        await InAppUpdate.startFlexibleUpdate();

        if (result == AppUpdateResult.success &&
            context.mounted) {
          _showAndroidCompleteSnackbar(context);
        }
      } else if (status != UpdateStatus.upToDate &&
          context.mounted) {
        await _showIOSUpdateDialog(
          context,
          status == UpdateStatus.forceUpdate,
        );
      }
    } catch (e) {
      debugPrint('Erro no In-App Update do Android: $e');

      // Não abre outro diálogo automaticamente quando
      // a API do Google Play falha. Isso evita avisos
      // repetidos em instalações de desenvolvimento.
    }
  }

  Future<void> _handleIOSUpdate(BuildContext context) async {
    final UpdateStatus status =
    await _checkFirebaseVersionStatus();

    if (status == UpdateStatus.upToDate) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    await _showIOSUpdateDialog(
      context,
      status == UpdateStatus.forceUpdate,
    );
  }

  Future<UpdateStatus> _checkFirebaseVersionStatus() async {
    try {
      final PackageInfo packageInfo =
      await PackageInfo.fromPlatform();

      final String currentVersion = packageInfo.version;
      final String minRequired =
      _remoteConfig.getString('min_version_required');
      final String latestVersion =
      _remoteConfig.getString('latest_version');

      if (_isVersionLower(currentVersion, minRequired)) {
        return UpdateStatus.forceUpdate;
      }

      if (_isVersionLower(currentVersion, latestVersion)) {
        return UpdateStatus.optionalUpdate;
      }
    } catch (e) {
      debugPrint('Erro ao comparar versões no Firebase: $e');
    }

    return UpdateStatus.upToDate;
  }

  bool _isVersionLower(String current, String target) {
    if (target.isEmpty) {
      return false;
    }

    try {
      final List<int> currentParts =
      current.split('.').map(int.parse).toList();
      final List<int> targetParts =
      target.split('.').map(int.parse).toList();

      for (int i = 0; i < targetParts.length; i++) {
        final int currentPart =
        i < currentParts.length ? currentParts[i] : 0;
        final int targetPart = targetParts[i];

        if (currentPart < targetPart) {
          return true;
        }

        if (currentPart > targetPart) {
          return false;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Versão inválida: $e');
      return false;
    }
  }

  void _showAndroidCompleteSnackbar(BuildContext context) {
    AppPopups.show(
      LocaleKeys.updateDownloaded.tr,
      type: PopupType.success,
      duration: const Duration(days: 1),
      actionLabel: LocaleKeys.restart.tr.toUpperCase(),
      onAction: () async {
        try {
          await InAppUpdate.completeFlexibleUpdate();
        } catch (e) {
          debugPrint(
            'Erro ao concluir atualização: $e',
          );
        }
      },
    );
  }

  Future<void> _showIOSUpdateDialog(
      BuildContext context,
      bool isForceUpdate,
      ) async {
    // Na atualização obrigatória o aviso volta a aparecer até o usuário
    // atualizar (não dá para fechar)
    do {
      final bool update = await AppPopups.alert(
        title: LocaleKeys.newVersionAvailable.tr,
        message: isForceUpdate
            ? LocaleKeys.mandatoryUpdateMessage.tr
            : LocaleKeys.optionalUpdateMessage.tr,
        icon: Icons.system_update_outlined,
        confirmText: LocaleKeys.update.tr,
        cancelText: isForceUpdate ? null : LocaleKeys.later.tr,
        dismissible: !isForceUpdate,
      );

      if (!update) return;
      await _openStore();
    } while (isForceUpdate);
  }

  Future<void> _openStore() async {
    final Uri url = Uri.parse(
      Platform.isIOS
          ? 'https://apps.apple.com/br/app/'
          'redes-comunicacionais-locais/'
          'id6759577931'
          : 'https://play.google.com/store/apps/'
          'details?id=br.uff.redescomunicacionais'
          '&hl=${AppTranslation.currentLocale}',
    );

    try {
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint(
          'Não foi possível abrir a loja.',
        );
      }
    } catch (e) {
      debugPrint(
        'Erro ao abrir a loja: $e',
      );
    }
  }
}
