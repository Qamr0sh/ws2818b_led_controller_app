import 'package:get/get.dart';
import 'package:ws2812b_panel_controller_app/Dashboard/UI/dashboard_controller.dart';

class DashboardBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(()=> DashboardController());
  }
}