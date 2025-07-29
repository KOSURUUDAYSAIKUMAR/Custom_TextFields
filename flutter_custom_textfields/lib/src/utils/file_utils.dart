import 'dart:io';
import 'package:flutter_custom_textfields/src/controllers/permission_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'gallery_saver.dart';

class FileUtils {
  static Future<String> saveToDownloads(File file) async {
    try {
      if (!await PermissionController.requestStorage()) {
        throw Exception('Storage permission denied');
      }
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Downloads directory not found');
      } else {
        final filePath = '${directory.path}/${file.uri.pathSegments.last}';
        final savedFile = await file.copy(filePath);
        await file.delete(); // Optionally delete the original file
        final result = await GallerySaver.saveToGallery(savedFile);
        if (result.isEmpty) {
          throw Exception('Failed to save file to gallery');
        }
        return savedFile.path;
      }
    } catch (e) {
      print('Error saving to downloads: $e');
      rethrow;
    }
  }

  static Future<void> shareImage(File file) async {
    try {
      final params = ShareParams(
        text: 'Great picture',
        files: [XFile(file.path)],
      );
      final result = await SharePlus.instance.share(params);
      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing the picture!');
      }
    } catch (e) {
      print('Error sharing image: $e');
    }
  }
}
