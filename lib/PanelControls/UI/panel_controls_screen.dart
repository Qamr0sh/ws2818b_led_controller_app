import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ws2812b_panel_controller_app/PanelControls/UI/panel_controller.dart';
import 'package:ws2812b_panel_controller_app/Resources/app_colors.dart';
import 'package:ws2812b_panel_controller_app/Resources/app_theme.dart';

class PanelControlsScreen extends GetView<PanelController>{
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PanelController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              controller.foundDevice.deviceName,
              style: appTheme.textTheme.headlineMedium,
            ),
            backgroundColor: AppColors.primaryBackgroundColor,
            elevation: 0,
            actions: [
              // Clear button
              IconButton(
                icon: const Icon(Icons.clear_all, color: AppColors.primaryColor),
                onPressed: controller.clearAll,
                tooltip: 'Clear All',
              ),
              // Fill button
              IconButton(
                icon: const Icon(Icons.format_color_fill, color: AppColors.primaryColor),
                onPressed: controller.fillAll,
                tooltip: 'Fill All',
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Color picker
                  _buildColorPalette(controller),
                  const SizedBox(height: 16),
                  // Grid view
                  Expanded(
                    child: _buildLightGrid(controller),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

  // Build the color palette
  Widget _buildColorPalette(PanelController controller) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.cyan,
      Colors.orange,
      Colors.white,
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = color == controller.selectedColor.value;

          return GestureDetector(
            onTap: () => controller.setColor(color),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Build the light grid
  Widget _buildLightGrid(PanelController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size to fit the grid in available space
        final cellSize = (constraints.maxWidth / controller.width) - 4;

        return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: controller.width,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: controller.width * controller.height,
            itemBuilder: (context, index) {
              final row = index ~/ controller.width;
              final col = index % controller.width;
              final light = controller.gridState[row][col];

              return Obx(
                () {
                  final isOn = light.isOn.value;
                  final color = light.color.value;

                  return GestureDetector(
                    onTap: () => controller.toggleLight(row, col),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isOn
                            ? color.withOpacity(0.8)
                            : Colors.grey[800]?.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isOn
                              ? color.withOpacity(0.9)
                              : Colors.grey[700]!,
                          width: 1,
                        ),
                        boxShadow: isOn
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isOn
                          ? Center(
                              child: Icon(
                                Icons.lightbulb,
                                color: color.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white,
                                size: 20,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          );
      },
    );
  }
