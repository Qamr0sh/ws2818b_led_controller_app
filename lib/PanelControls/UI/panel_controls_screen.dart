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
                color: AppColors.white,
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
                  const SizedBox(height: 20),
                  _buildEffectsControls(controller),
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

  // Build effects controls
  Widget _buildEffectsControls(PanelController controller) {
    var isActive = false.obs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Effects',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.effects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final effect = controller.effects[index];

              isActive.value = controller.currentEffect.value == effect;
              
              return Obx(()=> GestureDetector(
                onTap: () => controller.setEffect(effect),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive.value ? AppColors.primaryColor : Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive.value ? Colors.white : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (isActive.value)
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      effect,
                      style: TextStyle(
                        color: isActive.value ? Colors.white : Colors.grey[300],
                        fontWeight: isActive.value ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ));
            },
          )
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.currentEffect.value != 'None') {
            return Column(
              children: [
                Row(
                  children: [
                    const Text('Speed:', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: controller.effectSpeed.value.toDouble(),
                        min: 10,
                        max: 500,
                        divisions: 49,
                        label: '${controller.effectSpeed.value}ms',
                        onChanged: (value) {
                          controller.effectSpeed.value = value.toInt();
                        },
                      ),
                    ),
                  ],
                ),
                if (controller.currentEffect.value != 'Rainbow' && 
                    controller.currentEffect.value != 'Fire')
                  Row(
                    children: [
                      const Text('Color:', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final color = await showColorPickerDialog(
                            context: Get.context!,
                            initialColor: controller.effectColor.value,
                          );
                          if (color != null) {
                            controller.effectColor.value = color;
                          }
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: controller.effectColor.value,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: controller.stopEffect,
                        icon: const Icon(Icons.stop, size: 16),
                        label: const Text('Stop', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Future<Color?> showColorPickerDialog({
    required BuildContext context,
    required Color initialColor,
  }) async {
    Color selectedColor = initialColor;
    
    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0).toColor(),
                      const HSVColor.fromAHSV(1.0, 60.0, 1.0, 1.0).toColor(),
                      const HSVColor.fromAHSV(1.0, 120.0, 1.0, 1.0).toColor(),
                      const HSVColor.fromAHSV(1.0, 180.0, 1.0, 1.0).toColor(),
                      const HSVColor.fromAHSV(1.0, 240.0, 1.0, 1.0).toColor(),
                      const HSVColor.fromAHSV(1.0, 300.0, 1.0, 1.0).toColor(),
                      const HSVColor.fromAHSV(1.0, 360.0, 1.0, 1.0).toColor(),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RGB: ${selectedColor.red}, ${selectedColor.green}, ${selectedColor.blue}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'HEX: #${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(selectedColor),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Build the light grid
Widget _buildLightGrid(PanelController controller) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final cellSize = (constraints.maxWidth / controller.width) - 4;
      final gridHeight = cellSize * controller.height + 4 * (controller.height - 1);

      Set<String> toggledCells = {};

      return GestureDetector(
        onPanStart: (details) {
          toggledCells.clear();
        },
        onPanUpdate: (details) {
          // Get local position inside grid
          RenderBox box = context.findRenderObject() as RenderBox;
          Offset localPos = box.globalToLocal(details.globalPosition);

          // Calculate col & row
          int col = (localPos.dx / (cellSize + 4)).floor();
          int row = (localPos.dy / (cellSize + 4)).floor();

          // Bounds check
          if (row >= 0 && row < controller.height && col >= 0 && col < controller.width) {
            String cellKey = "$row-$col";

            if (!toggledCells.contains(cellKey)) {
              toggledCells.add(cellKey);
              controller.toggleLight(row, col);
            }
          }
        },
        child: SizedBox(
          width: constraints.maxWidth,
          height: gridHeight,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // disable scrolling to avoid conflict with drag
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: controller.width,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              mainAxisExtent: cellSize,
            ),
            itemCount: controller.width * controller.height,
            itemBuilder: (context, index) {
              final row = index ~/ controller.width;
              final col = index % controller.width;
              final light = controller.gridState[row][col];

              return Obx(() {
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
                        color: isOn ? color.withOpacity(0.9) : Colors.grey[700]!,
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
              });
            },
          ),
        ),
      );
    },
  );
}
