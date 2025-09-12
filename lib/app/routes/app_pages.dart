import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/dashboard/bindings/home_bindings.dart';
import 'package:redescomunicacionais/app/bindings/image_bindings.dart';
import 'package:redescomunicacionais/app/modules/login/bindings/login_bindings.dart';
import 'package:redescomunicacionais/app/modules/news/bindings/news_bindings.dart';
import 'package:redescomunicacionais/app/modules/user/bindings/user_bindings.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/modules/news/ui/create_news_form_page.dart';
import 'package:redescomunicacionais/app/modules/admin/ui/admin_page.dart';
import 'package:redescomunicacionais/app/modules/dashboard/ui/home_page.dart';
import 'package:redescomunicacionais/app/modules/inital/ui/initial_page.dart';
import 'package:redescomunicacionais/app/modules/login/ui/login_page.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_widget.dart';
import 'package:redescomunicacionais/app/modules/news/ui/news_page.dart';
import 'package:redescomunicacionais/app/modules/web/ui/webview_page.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.INITIAL,
      page: () => const InitialPage(),
    ),
    GetPage(name: Routes.LOGIN, page: () => const LoginPage(), binding: LoginBinding()),
    
    GetPage(name: Routes.ADMIN, page: () => AdminPage()),
    
    GetPage(
      name: Routes.HOME,
      page: () => HomePage(),
      bindings: [HomeBinding(), UserBinding(), NewsBinding()],
    ),
    GetPage(
      name: Routes.NEWS,
      page: () => NewsWidget(),
      binding: NewsBinding(),
    ),
    GetPage(
      name: Routes.NEWS_PAGE,
      page: () => const NewsPage(),
      binding: NewsBinding(),
    ),
    GetPage(
        name: Routes.CREATE_NEWS,
        page: () => const CreateNewsPage(),
        bindings: [NewsBinding(), HomeBinding(), ImageBinding()]),
    GetPage(name: Routes.WEB_VIEW, page: () => const WebViewPage()),
  ];
}
