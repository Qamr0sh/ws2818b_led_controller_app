import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ws2812b_panel_controller_app/Dashboard/UI/dashboard_controller.dart';
import 'package:ws2812b_panel_controller_app/Resources/app_colors.dart';
import 'package:ws2812b_panel_controller_app/Widgets/custom_button.dart';
import 'package:ws2812b_panel_controller_app/Resources/app_theme.dart';

class DashboardScreen extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06218,
            vertical: screenHeight * 0.02860,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Center(
                child: Text(
                  controller.foundDevices.isEmpty
                      ? "Your lights are waiting…\nTap below to find them."
                      : "Wow!\nYour panel is ready to shine."
                  ,
                  style: appTheme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              SizedBox(
                width: screenWidth * 0.5,
                child: Obx(
                  () => customButton(
                    label: controller.foundDevices.isEmpty
                        ? "Find them!"
                        : "Scan Again",
                    onTap: controller.startScan,
                    backgroundColor: AppColors.primaryColor,
                    isLoading: controller.isLoading
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Obx(
                () => Text(
                  controller.noNetworkError.value ??
                      controller.networkInfo.wifiName ??
                      "Not connected to Wi-Fi",
                  style: appTheme.textTheme.bodyLarge?.copyWith(
                    color: controller.noNetworkError.value != null
                        ? Colors.red
                        : AppColors.white,
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Found Devices List
              Expanded(
                child: Obx(() {
                  if (controller.foundDevices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No devices found yet\nTap the button above to start scanning',
                            textAlign: TextAlign.center,
                            style: appTheme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.foundDevices.length,
                    itemBuilder: (context, index) {
                      final device = controller.foundDevices[index];
                      return Container(

                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AppColors.primaryBackgroundColor,
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Device Header
                            Row(
                              children: [
                                const Icon(Icons.lightbulb, color: Colors.amber, size: 28),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    device.deviceName,
                                    style: appTheme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppColors.primaryColor,
                                  ),
                                  onPressed: () {
                                    controller.openLightControllers(index);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Device Properties
                            _buildInfoRow('IP Address', device.ip),
                            _buildInfoRow('Resolution', '${device.width} x ${device.height}'),
                            _buildInfoRow('Brightness', '${device.brightness}%'),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: appTheme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: appTheme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
