class DeviceInfo {
  final String deviceName;
  final int width;
  final int height;
  final int brightness;
  final String ip;

  DeviceInfo({
    required this.deviceName,
    required this.width,
    required this.height,
    required this.brightness,
    required this.ip,
  });

  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      deviceName: map['deviceName'] ?? 'Unknown Device',
      width: map['width'] ?? 0,
      height: map['height'] ?? 0,
      brightness: map['brightness'] ?? 0,
      ip: map['ip'] ?? '0.0.0.0',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceName': deviceName,
      'width': width,
      'height': height,
      'brightness': brightness,
      'ip': ip,
    };
  }
}
