import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionService extends GetxService {
  late final String appName;
  late final String packageName;
  late final String version;
  late final String buildNumber;

  VersionService();

  Future<VersionService> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    return this;
  }
}
