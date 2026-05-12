import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/admin/bindings/admin_binding.dart';
import 'package:redescomunicacionais/app/modules/central_de_comunicacao/bindings/cdc_bindings.dart';
import 'package:redescomunicacionais/app/modules/central_de_comunicacao/ui/cdc_page.dart';
import 'package:redescomunicacionais/app/modules/connections/bindings/connections_bindings.dart';
import 'package:redescomunicacionais/app/modules/connections/ui/connections_page.dart';
import 'package:redescomunicacionais/app/modules/dashboard/bindings/home_bindings.dart';
import 'package:redescomunicacionais/app/data/bindings/image_bindings.dart';
import 'package:redescomunicacionais/app/modules/login/bindings/login_bindings.dart';
import 'package:redescomunicacionais/app/modules/news/bindings/news_bindings.dart';
import 'package:redescomunicacionais/app/modules/news_center/bindings/news_center_bindings.dart';
import 'package:redescomunicacionais/app/modules/news_center/ui/news_center_page.dart';
import 'package:redescomunicacionais/app/modules/splash/bindings/splash_bindings.dart';
import 'package:redescomunicacionais/app/modules/user/bindings/user_bindings.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/modules/news/ui/create_news_form_page.dart';
import 'package:redescomunicacionais/app/modules/admin/ui/admin_page.dart';
import 'package:redescomunicacionais/app/modules/dashboard/ui/home_page.dart';
import 'package:redescomunicacionais/app/modules/splash/ui/splash_page.dart';
import 'package:redescomunicacionais/app/modules/login/ui/login_page.dart';
import 'package:redescomunicacionais/app/modules/news/ui/news_windows.page.dart';
import 'package:redescomunicacionais/app/modules/news/ui/news_page.dart';
import 'package:redescomunicacionais/app/modules/user/ui/user_page.dart';
import 'package:redescomunicacionais/app/modules/web/ui/webview_page.dart';
import 'package:redescomunicacionais/app/modules/news/ui/edit_news_page.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.INITIAL,
      page: () => SplashPage(),
      bindings: [LoginBinding(), SplashBindings()],
    ),
    GetPage(
        name: Routes.LOGIN,
        page: () => const LoginPage(),
        bindings: [LoginBinding()]),
    GetPage(
      name: Routes.ADMIN,
      page: () => AdminPage(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomePage(),
      bindings: [UserBinding(), HomeBinding(), NewsBinding(), ConnectionsBindings()],
    ),
    GetPage(
      name: Routes.NEWS,
      page: () => NewsWindowsPage(),
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
    GetPage(
      name: Routes.EDIT_NEWS,
      page: () => const EditNewsPage(),
      binding: NewsBinding(), // Usando o mesmo binding do módulo news
    ),
    GetPage(
      name: Routes.CENTRAL_DE_COMUNICACAO,
      page: () => CentralDeComunicacaoPage(),
      binding: CentralDeComunicacaoBinding(),
    ),
    GetPage(
      name: Routes.USER,
      page: () => UserPage(),
      binding: UserBinding(),
    ),
    GetPage(
      name: Routes.NEWSCENTER,
      page: () => NewsCenterPage(),
      bindings: [NewsCenterBinding(), HomeBinding(), NewsBinding()],
    ),
    GetPage(
      name: Routes.CONNECTIONS,
      page: () => const ConnectionsPage(),
      binding: ConnectionsBindings(),
    ),
  ];
}
