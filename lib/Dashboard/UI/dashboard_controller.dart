import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:ws2812b_panel_controller_app/GlobalUsecases/GetNetworkInfo/get_network_info_usecase.dart';
import 'package:ws2812b_panel_controller_app/Models/network_info.dart';
import 'package:ws2812b_panel_controller_app/Models/device_info.dart';

class FoundDevice {
  final String ip;
  final DeviceInfo? info;

  FoundDevice({required this.ip, Map<String, dynamic>? infoMap}) 
    : info = infoMap != null ? DeviceInfo.fromMap(infoMap) : null;

  String get deviceName => info?.deviceName ?? 'Unknown Device';
  int get width => info?.width ?? 0;
  int get height => info?.height ?? 0;
  int get brightness => info?.brightness ?? 0;
}

class DashboardController extends GetxController {
  var networkName = "".obs;
  RxnString noNetworkError = RxnString();
  CustomNetworkInfoModel networkInfo =
  CustomNetworkInfoModel(wifiName: "", ip: "", subnet: "");
  var isLoading = false.obs;

  GetNetworkInfoUseCase getNetworkInfoUseCase;

  /// List of found devices (reactive)
  RxList<FoundDevice> foundDevices = <FoundDevice>[].obs;

  DashboardController({required this.getNetworkInfoUseCase});

  @override
  void onInit() {
    super.onInit();
    getWifiName();
  }

  void getWifiName() {
    getNetworkInfoUseCase.getNetworkInfo().then((value) {
      if (value.wifiName != null) {
        networkName.value = value.wifiName!;
        networkInfo.ip = value.ip;
        networkInfo.subnet = value.subnet;
        networkInfo.wifiName = value.wifiName;
      } else {
        noNetworkError.value = "❌ Not connected to Wi-Fi";
      }
    });
  }

  void startScan() async {
    isLoading.value = true;
    String? localIp = networkInfo.ip; // e.g., 10.10.10.45
    String? subnetMask = networkInfo.subnet; // e.g., 255.255.255.192

    if (localIp == null || subnetMask == null) {
      print("❌ Not connected to Wi-Fi");
      return;
    }

    List<String> ipParts = localIp.split('.');
    List<String> maskParts = subnetMask.split('.');

    if (ipParts.length != 4 || maskParts.length != 4) {
      print("❌ Invalid IP or Subnet Mask");
      return;
    }

    // Calculate network range
    List<int> ipBytes = ipParts.map(int.parse).toList();
    List<int> maskBytes = maskParts.map(int.parse).toList();

    List<int> networkBytes =
    List.generate(4, (i) => ipBytes[i] & maskBytes[i]);
    List<int> broadcastBytes =
    List.generate(4, (i) => networkBytes[i] | (~maskBytes[i] & 0xFF));

    String subnetPrefix = "${ipBytes[0]}.${ipBytes[1]}.${ipBytes[2]}";
    int start = networkBytes[3] + 1;
    int end = broadcastBytes[3] - 1;

    print("📡 Scanning $subnetPrefix.$start → $subnetPrefix.$end");

    foundDevices.clear(); // reset before each scan

    for (int i = start; i <= end; i++) {
      if (i == ipBytes[3]) continue; // skip own IP
      String ip = "$subnetPrefix.$i";
      print("🔍 scanning: $ip");
      _scanIp(ip);
      await Future.delayed(const Duration(milliseconds: 50));
    }
    isLoading.value = false;
  }

  Future<void> _scanIp(String ip) async {
    try {
      final socket =
      await Socket.connect(ip, 4405, timeout: const Duration(milliseconds: 300));

      print("✅ Device found at $ip");

      // Try to read JSON info if available
      socket.setOption(SocketOption.tcpNoDelay, true);
      socket.timeout(const Duration(milliseconds: 200));

      String rawData = "";
      try {
        rawData = await socket.cast<List<int>>().transform(utf8.decoder).first;
      } catch (_) {}

      Map<String, dynamic>? deviceInfo;
      if (rawData.isNotEmpty) {
        try {
          deviceInfo = Map<String, dynamic>.from(
              jsonDecode(rawData.trim()));

          print(deviceInfo);
        } catch (_) {
          deviceInfo = null; // not JSON
        }
      }

      foundDevices.add(FoundDevice(ip: ip, infoMap: deviceInfo));
      socket.destroy();
    } catch (_) {}
  }

  void openLightControllers(int index){
      Get.toNamed("/panel", arguments: {"device": foundDevices[index]});
  }
}
