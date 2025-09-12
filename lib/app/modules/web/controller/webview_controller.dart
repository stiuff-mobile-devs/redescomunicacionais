import 'package:get/get.dart';
import 'package:redescomunicacionais/app/utils/components/custom_alert_dialog.dart';
import 'package:redescomunicacionais/app/utils/components/uri_launcher_helper.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart'; // Adicionado para kIsWeb
import 'package:url_launcher/url_launcher.dart'; // Adicionado para abrir links na web

class WebViewPageController extends GetxController {
  void goDocPage() {
    /* Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url': '',
      'title': 'services'.tr,
    });*/
    customAlertDialog(Get.context!, title: 'page_under_development'.tr).show();
  }

  // final _obj = ''.obs;
  // set obj(value) => _obj.value = value;
  // get obj => _obj.value;
  String url = Get.arguments['url'];
  String title = Get.arguments['title'];
  bool interrogation = Get.arguments['interrogation'] ?? false;
  WebViewController? wvc; // Torna nullable

  @override
  void onInit() {
    if (!kIsWeb) {
      wvc = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(url));
    }
    super.onInit();
  }

  Future<void> openUrlInBrowser() async {
    print('Tentando abrir o link: $url'); // Debug
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(
        uri,
        webOnlyWindowName: '_blank',
      );
      print('Resultado do launchUrl: $launched'); // Debug
      if (!launched) {
        customAlertDialog(Get.context!, title: 'Não foi possível abrir o link')
            .show();
      }
    } else {
      print('canLaunchUrl retornou false'); // Debug
      customAlertDialog(Get.context!, title: 'Não foi possível abrir o link')
          .show();
    }
  }

  void closeWebView() {
    customCloseWebView();
  }
}
