import 'package:network_info_plus/network_info_plus.dart';
import 'package:ws2812b_panel_controller_app/GlobalUsecases/GetNetworkInfo/get_network_info_usecase.dart';

import '../../Models/network_info.dart';

class GetNetworkInfoUseCaseImpl extends GetNetworkInfoUseCase{

  final network = NetworkInfo();
  @override
  Future<CustomNetworkInfoModel> getNetworkInfo() async{
    return CustomNetworkInfoModel(wifiName: await network.getWifiName(), ip: await network.getWifiIP(), subnet: await network.getWifiSubmask());
  }
}