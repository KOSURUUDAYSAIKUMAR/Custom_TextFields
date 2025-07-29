import 'dart:io';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

enum SaveType { localImage, networkImage, gif, video }

class GallerySaver {
  static Future<String> saveToGallery(File imageFile) async {
    try {
      final result = await ImageGallerySaverPlus.saveFile(imageFile.path);

      if (result != null && result['isSuccess'] == true) {
        return result['filePath'] ?? imageFile.path;
      } else {
        throw Exception('Save failed: ${result?['errorMessage']}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
