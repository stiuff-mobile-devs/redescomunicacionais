import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/web/controller/webview_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart'; // Adicionado para kIsWeb

class WebViewPage extends StatelessWidget {
  const WebViewPage({Key? key}) : super(key: key);

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
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async {
                      if (!kIsWeb &&
                          controller.wvc != null &&
                          await controller.wvc!.canGoBack()) {
                        controller.wvc!.goBack();
                      } else {
                        Get.back();
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(child: Center(child: Text(controller.title))),
                  IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.close)),
                  controller.interrogation
                      ? IconButton(
                          onPressed: () {
                            controller.goDocPage();
                          },
                          icon: const Icon(
                            Icons.question_mark,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(
                          width: 0,
                        ),
                ],
              ),
            ),
            body: kIsWeb
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.open_in_new,
                            size: 48, color: Colors.black54),
                        const SizedBox(height: 16),
                        Text('Abrindo link em nova aba...',
                            style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  )
                : (controller.wvc != null
                    ? WebViewWidget(controller: controller.wvc!)
                    : const Center(child: CircularProgressIndicator())),
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
