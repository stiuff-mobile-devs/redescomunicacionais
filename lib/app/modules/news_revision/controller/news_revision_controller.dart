import 'package:get/get.dart';

class NewsRevisionController extends GetxController {

NewsRevisionController();

  final _obj = ''.obs;
  set obj(value) => this._obj.value = value;
  get obj => this._obj.value;
}