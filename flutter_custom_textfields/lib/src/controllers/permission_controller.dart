import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionController {
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  static Future<bool> requestStorage() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) return true;

      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission
  }

  static Future<bool> requestAll() async {
    final permissions =
        Platform.isAndroid
            ? [Permission.camera, Permission.location, Permission.storage]
            : [Permission.camera, Permission.location];

    final results = await permissions.request();
    return results.values.every((status) => status.isGranted);
  }

  static Future<bool> checkGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }
}
