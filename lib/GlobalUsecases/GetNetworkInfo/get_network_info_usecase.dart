import 'package:ws2812b_panel_controller_app/Models/network_info.dart';

abstract class GetNetworkInfoUseCase{
  Future<CustomNetworkInfoModel> getNetworkInfo();
}