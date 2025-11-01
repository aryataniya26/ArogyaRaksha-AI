import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Request Location Permission
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Check Location Permission
  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // Request Camera Permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request Storage Permission
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Request Notification Permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Request Phone Permission (for SMS/Calls)
  static Future<bool> requestPhonePermission() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  // Request SMS Permission
  static Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  // Request Microphone Permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Request Bluetooth Permission
  static Future<bool> requestBluetoothPermission() async {
    final status = await Permission.bluetooth.request();
    return status.isGranted;
  }

  // Request All Emergency Permissions
  static Future<Map<String, bool>> requestAllEmergencyPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.phone,
      Permission.sms,
      Permission.notification,
    ].request();

    return {
      'location': statuses[Permission.location]?.isGranted ?? false,
      'phone': statuses[Permission.phone]?.isGranted ?? false,
      'sms': statuses[Permission.sms]?.isGranted ?? false,
      'notification': statuses[Permission.notification]?.isGranted ?? false,
    };
  }

  // Open App Settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied(
      Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }
}