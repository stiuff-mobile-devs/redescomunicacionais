import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/utils/components/uri_launcher_helper.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart'; // Adicionado para kIsWeb
import 'package:url_launcher/url_launcher.dart'; // Adicionado para abrir links na web

class WebViewPageController extends GetxController {
  void goDocPage() {
    /* Get.toNamed(Routes.WEB_VIEW, arguments: {
      'url': '',
      'title': LocaleKeys.services.tr,
    });*/
    AppPopups.info(LocaleKeys.pageUnderDevelopment.tr);
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
        AppPopups.error(LocaleKeys.couldNotOpenLink.tr);
      }
    } else {
      print('canLaunchUrl retornou false'); // Debug
      AppPopups.error(LocaleKeys.couldNotOpenLink.tr);
    }
  }

  void closeWebView() {
    customCloseWebView();
  }
}
