import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ws2812b_panel_controller_app/Resources/app_colors.dart';

import '../../Dashboard/UI/dashboard_controller.dart';

class LightState {
  final int row;
  final int col;
  RxBool isOn;
  Rx<Color> color;

  LightState({
    required this.row,
    required this.col,
    bool isOn = false,
    Color color = Colors.white,
  })  : isOn = isOn.obs,
        color = color.obs;
}

class PanelController extends GetxController {
  final FoundDevice foundDevice = Get.arguments["device"];
  Socket? _socket;
  late final int width;
  late final int height;

  late final List<List<LightState>> gridState; // [row][col]
  final Rx<Color> selectedColor = Colors.white.obs;
  final RxString currentEffect = 'None'.obs;
  final RxBool isEffectRunning = false.obs;
  Timer? _effectTimer;
  
  // Available effects
  final List<String> effects = [
    'None', 
    'Rainbow', 
    'Fire', 
    'Color Wipe', 
    'Theater Chase', 
    'Scanner',
    'Heart',
    'Smile',
    'Star',
    'Pac-Man',
    'Mario'
  ];

  // Effect parameters
  final RxInt effectSpeed = 100.obs; // ms between updates
  final Rx<Color> effectColor = Colors.blue.obs;

  // Custom LED mapping: maps UI position (row, col) to physical LED index
  late final List<List<int>> customLedMap;

  // Pixel art patterns
  final Map<String, List<List<int>>> _pixelArt = {
    'Heart': [
      [0, 1, 0, 0, 0, 1, 0],
      [1, 1, 1, 0, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1],
      [0, 1, 1, 1, 1, 1, 0],
      [0, 0, 1, 1, 1, 0, 0],
      [0, 0, 0, 1, 0, 0, 0],
    ],
    'Smile': [
      [0, 0, 1, 1, 1, 1, 0, 0],
      [0, 1, 0, 0, 0, 0, 1, 0],
      [1, 0, 1, 0, 0, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 0, 0, 1, 0, 1],
      [1, 0, 0, 1, 1, 0, 0, 1],
      [0, 1, 0, 0, 0, 0, 1, 0],
      [0, 0, 1, 1, 1, 1, 0, 0],
    ],
    'Star': [
      [0, 0, 0, 1, 0, 0, 0],
      [0, 0, 1, 1, 1, 0, 0],
      [1, 1, 1, 1, 1, 1, 1],
      [0, 1, 1, 1, 1, 1, 0],
      [0, 0, 1, 1, 1, 0, 0],
      [0, 1, 0, 0, 0, 1, 0],
      [1, 0, 0, 0, 0, 0, 1],
    ],
    'Pac-Man': [
      [0, 1, 1, 1, 1, 1, 0],
      [1, 1, 1, 1, 1, 1, 1],
      [1, 1, 0, 0, 0, 1, 1],
      [1, 1, 1, 1, 0, 1, 1],
      [1, 1, 1, 0, 0, 1, 1],
      [1, 1, 0, 0, 0, 1, 1],
      [1, 1, 1, 1, 1, 1, 1],
      [0, 1, 1, 1, 1, 1, 0],
    ],
    'Mario': [
      [0, 0, 1, 1, 1, 1, 0, 0],
      [0, 0, 1, 1, 1, 1, 0, 0],
      [0, 0, 0, 1, 1, 0, 0, 0],
      [0, 1, 1, 1, 1, 1, 1, 0],
      [1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 1, 0, 0, 1, 0, 1],
      [1, 1, 1, 0, 0, 1, 1, 1],
    ]
  };
  
  // Colors for pixel art
  final Map<String, Color> _pixelArtColors = {
    'Heart': Colors.red,
    'Smile': Colors.yellow,
    'Star': Colors.yellow,
    'Pac-Man': Colors.yellow,
    'Mario': Colors.red,
  };

  @override
  void onInit() {
    super.onInit();
    width = foundDevice.width;
    height = foundDevice.height;

    // Initialize grid with all lights OFF
    gridState = List.generate(
      height,
          (row) => List.generate(
        width,
            (col) => LightState(row: row, col: col),
      ),
    );

    // Initialize custom LED mapping
    _initializeCustomLedMap();

    connectToESP(foundDevice.ip, 4405);

    lightUpByPhysicalIndex(16, AppColors.primaryColor);
  }

  void lightUpByPhysicalIndex(int physicalIndex, Color color) {
    clearAll();

    // Find all UI cells mapped to the physicalIndex and turn them on
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if (_getPhysicalLedIndex(row, col) == physicalIndex) {
          gridState[row][col].isOn.value = true;
          gridState[row][col].color.value = color;
        }
      }
    }

    updatePanel();
  }

  void _initializeCustomLedMap() {
    customLedMap = List.generate(height, (row) => List.generate(width, (col) => 0));
     _createManualMapping();

  }

  /// Define exactly which LED each UI position should control
  void _createManualMapping() {
    // Initialize all to -1 (unmapped)
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        customLedMap[row][col] = -1;
      }
    }

    int ledIndex = 0;
    // List of columns to reverse the row iteration order
    final reverseCols = {2, 3, 6, 7, 10, 11, 14, 15};

    for (int col = 0; col < width; col++) {
      if (reverseCols.contains(col)) {
        // For these columns, iterate rows top to bottom (0 to height-1)
        for (int row = 0; row < height; row++) {
          if (ledIndex >= width * height) break;
          customLedMap[row][col] = ledIndex;
          ledIndex++;
        }
      } else {
        // For other columns, iterate rows bottom to top (height-1 down to 0)
        for (int row = height - 1; row >= 0; row--) {
          if (ledIndex >= width * height) break;
          customLedMap[row][col] = ledIndex;
          ledIndex++;
        }
      }
    }

    // Now swap the specified column pairs:
    void swapColumns(int colA, int colB) {
      for (int row = 0; row < height; row++) {
        int temp = customLedMap[row][colA];
        customLedMap[row][colA] = customLedMap[row][colB];
        customLedMap[row][colB] = temp;
      }
    }

    swapColumns(2, 3);
    swapColumns(6, 7);
    swapColumns(10, 11);
    swapColumns(14, 15);
  }

  /// Get the physical LED index for a UI grid position
  int _getPhysicalLedIndex(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) {
      return -1; // Invalid position
    }
    return customLedMap[row][col];
  }

  Future<void> connectToESP(String ip, int port) async {
    try {
      print("✅ Connecting to $ip:$port");
      _socket =
      await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
      print("✅ Connected to $ip:$port");

      String buffer = "";

      _socket!.listen(
            (data) {
          try {
            buffer += utf8.decode(data);
            final newlineIndex = buffer.indexOf('\n');
            if (newlineIndex != -1) {
              final jsonPart = buffer.substring(0, newlineIndex).trim();
              buffer = buffer.substring(newlineIndex + 1);

              try {
                final info = jsonDecode(jsonPart);
                print("📩 Device Info: $info");
                updatePanel(); // Send initial all-off frame
              } catch (e) {
                print("⚠️ Failed to parse JSON: $jsonPart. Error: $e");
              }
            }
          } catch (e) {
            print("⚠️ Error processing socket data: $e");
          }
        },
        onError: (error) => print("❌ Socket Error: $error"),
        onDone: () => print("🔌 Socket closed"),
      );
    } catch (e) {
      print("❌ Connection Failed: $e");
      Get.snackbar("Connection Error", "Failed to connect to the device");
    }
  }

  /// Toggle a single light
  void toggleLight(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) return;

    final light = gridState[row][col]; // ✅ Correct indexing
    light.isOn.value = !light.isOn.value;
    if (light.isOn.value) {
      light.color.value = selectedColor.value;
    }

    updatePanel();
  }


  /// Send frame data using custom LED mapping
  void updatePanel() {
    if (_socket == null) return;

    final frame = Uint8List(width * height * 3);

    // Use custom mapping to place each UI grid position to its physical LED
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final light = gridState[row][col];
        final physicalLedIndex = _getPhysicalLedIndex(row, col);

        // Skip invalid mappings
        if (physicalLedIndex < 0 || physicalLedIndex >= width * height) continue;

        final index = physicalLedIndex * 3;

        if (light.isOn.value) {
          final color = light.color.value;
          frame[index] = color.red;
          frame[index + 1] = color.green;
          frame[index + 2] = color.blue;

          // Debug: Print first few lit pixels
          if (physicalLedIndex < 5) {
            print("🔍 Custom Map: UI(row=$row,col=$col) -> Physical LED=$physicalLedIndex, RGB=(${color.red},${color.green},${color.blue})");
          }
        } else {
          frame[index] = 0;
          frame[index + 1] = 0;
          frame[index + 2] = 0;
        }
      }
    }

    _socket?.add(frame);
    print("📤 Sent frame: ${frame.length} bytes");
  }

  /// Turn OFF all lights
  void clearAll() {
    for (var row in gridState) {
      for (var light in row) {
        light.isOn.value = false;
      }
    }
    updatePanel();
  }

  /// Turn ON all lights with selected color
  void fillAll() {
    for (var row in gridState) {
      for (var light in row) {
        light.isOn.value = true;
        light.color.value = selectedColor.value;
      }
    }
    updatePanel();
  }

  /// Set currently selected color
  void setColor(Color color) {
    selectedColor.value = color;
  }

  // Effect methods
  void setEffect(String effectName) {
    // Stop any running effect
    stopEffect();
    
    currentEffect.value = effectName;
    
    if (effectName == 'None') {
      return;
    }
    
    isEffectRunning.value = true;
    _runEffect();
  }
  
  void stopEffect() {
    _effectTimer?.cancel();
    isEffectRunning.value = false;
    clearAll();
  }
  
  void _runEffect() {
    if (_effectTimer != null) {
      _effectTimer!.cancel();
    }

    if (currentEffect.value == 'None') {
      isEffectRunning.value = false;
      return;
    }

    // Check if it's a pixel art effect
    if (_pixelArt.containsKey(currentEffect.value)) {
      _drawPixelArt(currentEffect.value);
      updatePanel();
      return;
    }

    isEffectRunning.value = true;
    _effectTimer = Timer.periodic(Duration(milliseconds: effectSpeed.value), (timer) {
      switch (currentEffect.value) {
        case 'Rainbow':
          _rainbowEffect();
          break;
        case 'Fire':
          _fireEffect();
          break;
        case 'Color Wipe':
          _colorWipeEffect();
          break;
        case 'Theater Chase':
          _theaterChaseEffect();
          break;
        case 'Scanner':
          _scannerEffect();
          break;
      }
      updatePanel();
    });
  }
  
  void _drawPixelArt(String artName) {
    if (!_pixelArt.containsKey(artName)) return;
    
    final pattern = _pixelArt[artName]!;
    final artColor = _pixelArtColors[artName] ?? Colors.white;
    
    // Clear the grid
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        gridState[row][col].isOn.value = false;
        gridState[row][col].color.value = Colors.black;
      }
    }
    
    // Calculate position to center the pixel art
    int startRow = (height - pattern.length) ~/ 2;
    int startCol = (width - pattern[0].length) ~/ 2;
    
    // Draw the pixel art
    for (int row = 0; row < pattern.length; row++) {
      for (int col = 0; col < pattern[row].length; col++) {
        int targetRow = startRow + row;
        int targetCol = startCol + col;
        
        if (targetRow >= 0 && targetRow < height && targetCol >= 0 && targetCol < width) {
          if (pattern[row][col] == 1) {
            gridState[targetRow][targetCol].isOn.value = true;
            gridState[targetRow][targetCol].color.value = artColor;
          } else {
            gridState[targetRow][targetCol].isOn.value = false;
          }
        }
      }
    }
  }

  /// Effect implementations
  void _rainbowEffect() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hue = (now / 20) % 360;
    
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final hueShift = (hue + (row * 10) + (col * 5)) % 360;
        gridState[row][col].color.value = HSVColor.fromAHSV(1.0, hueShift, 1.0, 1.0).toColor();
        gridState[row][col].isOn.value = true;
      }
    }
  }
  
  void _fireEffect() {
    // Cool fire effect using noise and color gradients
    final now = DateTime.now().millisecondsSinceEpoch;
    
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        // Simple noise-based fire effect
        final noise = (math.sin(now * 0.001 + col * 0.2) + 1) / 2;
        final heat = (row / height) * noise;
        
        // Map heat to color (black -> red -> orange -> yellow -> white)
        Color color;
        if (heat < 0.4) {
          color = Colors.black;
        } else if (heat < 0.6) {
          final t = (heat - 0.4) * 5;
          color = Color.lerp(Colors.red, Colors.orange, t)!;
        } else if (heat < 0.8) {
          final t = (heat - 0.6) * 5;
          color = Color.lerp(Colors.orange, Colors.yellow, t)!;
        } else {
          final t = (heat - 0.8) * 5;
          color = Color.lerp(Colors.yellow, Colors.white, t)!;
        }
        
        gridState[row][col].color.value = color;
        gridState[row][col].isOn.value = true;
      }
    }
  }
  
  void _colorWipeEffect() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final pos = ((now / 50) % (width * 2)).toInt();
    
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final index = row * width + col;
        if (index <= pos && pos - index < width) {
          gridState[row][col].color.value = effectColor.value;
          gridState[row][col].isOn.value = true;
        } else {
          gridState[row][col].isOn.value = false;
        }
      }
    }
  }
  
  void _theaterChaseEffect() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final frame = ((now / 100) % 3).toInt();
    
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        if ((row + col + frame) % 3 == 0) {
          gridState[row][col].color.value = effectColor.value;
          gridState[row][col].isOn.value = true;
        } else {
          gridState[row][col].isOn.value = false;
        }
      }
    }
  }
  
  void _scannerEffect() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final pos = ((now / 30) % (width * 2 - 2)).toInt();
    
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final distance = (pos - col).abs();
        if (distance < 3) {
          final brightness = 1.0 - (distance / 3.0);
          gridState[row][col].color.value = effectColor.value.withOpacity(brightness);
          gridState[row][col].isOn.value = true;
        } else {
          gridState[row][col].isOn.value = false;
        }
      }
    }
  }

  @override
  void onClose() {
    _effectTimer?.cancel();
    _socket?.destroy();
    _socket = null;
    super.onClose();
  }
}