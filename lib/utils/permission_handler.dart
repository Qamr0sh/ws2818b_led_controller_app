import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  // Request location permission (required for network scanning on Android 10+)
  static Future<bool> requestLocationPermission() async {
    // Check if permission is already granted
    var status = await Permission.location.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // Request permission if not granted or denied
    if (status.isDenied) {
      status = await Permission.location.request();
      
      // If permission is permanently denied, open app settings
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
    }
    
    return status.isGranted;
  }

  // Request nearby devices permission (required for Android 12+)
  static Future<bool> requestNearbyDevicesPermission() async {
    // Check Android version
    if (!await Permission.nearbyWifiDevices.isRestricted) {
      return true;
    }

    // Check if permission is already granted
    var status = await Permission.nearbyWifiDevices.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // Request permission if not granted or denied
    if (status.isDenied) {
      status = await Permission.nearbyWifiDevices.request();
      
      // If permission is permanently denied, open app settings
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
    }
    
    return status.isGranted;
  }

  // Check if all required permissions are granted
  static Future<bool> checkAndRequestPermissions() async {
    bool locationGranted = await requestLocationPermission();
    bool nearbyDevicesGranted = await requestNearbyDevicesPermission();
    
    return locationGranted && nearbyDevicesGranted;
  }
}
