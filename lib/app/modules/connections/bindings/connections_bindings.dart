import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/connections/controller/connections_controller.dart';

class ConnectionsBindings implements Bindings {
@override
void dependencies() {
  Get.put<ConnectionsController>(ConnectionsController(), permanent: true);
  }
}