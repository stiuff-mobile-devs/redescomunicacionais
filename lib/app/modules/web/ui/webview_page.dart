import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/web/controller/webview_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:redescomunicacionais/app/modules/utils/widgets/blinking_loading_icon.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_bars.dart';
import 'package:flutter/foundation.dart'; // Adicionado para kIsWeb

class WebViewPage extends StatelessWidget {
  const WebViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WebViewPageController>(
      init: WebViewPageController(),
      builder: (controller) {
        if (kIsWeb) {
          // Abre o link automaticamente ao construir o widget
          Future.microtask(() => controller.openUrlInBrowser());
        }
        return WillPopScope(
          onWillPop: () => onExit(controller),
          child: Scaffold(
            appBar: AppBars.build(
              title: controller.title,
              // Voltar navega no histórico da página antes de sair
              leading: IconButton(
                onPressed: () async {
                  if (!kIsWeb &&
                      controller.wvc != null &&
                      await controller.wvc!.canGoBack()) {
                    controller.wvc!.goBack();
                  } else {
                    Get.back();
                  }
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              actions: [
                if (controller.interrogation)
                  IconButton(
                    onPressed: controller.goDocPage,
                    icon: const Icon(Icons.help_outline),
                  ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: kIsWeb
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.open_in_new,
                            size: 48, color: Colors.black54),
                        const SizedBox(height: 16),
                        Text(LocaleKeys.openingLinkNewTab.tr,
                            style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  )
                : (controller.wvc != null
                    ? WebViewWidget(controller: controller.wvc!)
                    : const Center(
                        child: BlinkingLoadingIcon(
                          size: 36,
                          color: Colors.black54,
                        ),
                      )),
          ),
        );
      },
    );
  }

  Future<bool> onExit(WebViewPageController controller) async {
    if (!kIsWeb &&
        controller.wvc != null &&
        await controller.wvc!.canGoBack()) {
      controller.wvc!.goBack();
      return Future.value(false);
    }
    return Future.value(true);
  }
}
