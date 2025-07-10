import 'dart:io';
import 'package:image/image.dart' as img;

class WatermarkUtil {
  static Future<File> applyWaterMark(
    File original,
    String text,
    int? x,
    int? y,
  ) async {
    final bytes = await original.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      return original;
    }
    final img.BitmapFont font = img.arial24;
    final img.Color textColor = img.ColorRgb8(255, 255, 255);

    img.drawString(
      image,
      font: font,
      x: x ?? 10,
      y: image.height - (y ?? 30),
      text,
      color: textColor,
    );
    final jpg = img.encodeJpg(image);
    return original.writeAsBytes(jpg, flush: true);
  }
}
