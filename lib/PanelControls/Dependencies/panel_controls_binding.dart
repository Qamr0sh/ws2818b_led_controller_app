import 'package:get/get.dart';
import 'package:ws2812b_panel_controller_app/PanelControls/UI/panel_controller.dart';

class PanelControlBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<PanelController>(PanelController(), permanent: true);
  }
}