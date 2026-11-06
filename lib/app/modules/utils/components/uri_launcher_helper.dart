import 'package:url_launcher/url_launcher.dart';

void openUrl(String url,{bool openNativeApp = false, bool enableJavaScript = true}){

  launchUrl(
      Uri.parse(url), 
      mode: openNativeApp ? LaunchMode.externalApplication : LaunchMode.inAppWebView,
      webViewConfiguration: WebViewConfiguration(enableJavaScript: enableJavaScript)
  );
  
}

void customCloseWebView(){
  closeInAppWebView();
}