import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class WatermarkUtil {
  static Future<File> addWatermark({
    required File imageFile,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes)!;

    // Colors for the watermark
    final img.Color whiteTextColor = img.ColorRgba8(255, 255, 255, 255);
    final img.Color blackBackground = img.ColorRgba8(0, 0, 0, 200);
    final img.Color accentColor = img.ColorRgba8(
      76,
      175,
      80,
      255,
    ); // Green accent

    // Format date and time
    final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());

    // Format coordinates
    final locationText =
        'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';

    // Clean up address
    final cleanAddress = address.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Use available fonts from image package
    final titleFont = img.arial24;
    final bodyFont = img.arial24;

    // Calculate dimensions
    final padding = (image.width * 0.02).toInt().clamp(15, 30);
    final lineHeight = 28;

    // Split address into lines
    final addressLines = _splitAddress(cleanAddress, 45);

    // Calculate watermark height
    final watermarkHeight =
        (padding * 2) +
        lineHeight + // Location
        (addressLines.length * lineHeight) + // Address lines
        lineHeight + // Date
        lineHeight; // Time

    // Draw background rectangle
    img.fillRect(
      image,
      x1: 0,
      y1: image.height - watermarkHeight,
      x2: image.width,
      y2: image.height,
      color: blackBackground,
    );

    // Add a subtle border at the top
    for (int i = 0; i < 3; i++) {
      img.drawLine(
        image,
        x1: 0,
        y1: image.height - watermarkHeight + i,
        x2: image.width,
        y2: image.height - watermarkHeight + i,
        color: accentColor,
      );
    }

    // Starting position for text
    int currentY = image.height - watermarkHeight + padding;

    // Draw location icon (simple circle)
    final iconSize = 6;
    img.fillCircle(
      image,
      x: padding + iconSize,
      y: currentY + (lineHeight ~/ 2),
      radius: iconSize,
      color: accentColor,
    );

    // Draw coordinates
    img.drawString(
      image,
      locationText,
      font: titleFont,
      x: padding + (iconSize * 3),
      y: currentY,
      color: whiteTextColor,
    );
    currentY += lineHeight;

    // Draw address lines
    for (int i = 0; i < addressLines.length; i++) {
      final line = addressLines[i];

      // Add a small indent for address lines
      final addressIndent = padding + 15;

      img.drawString(
        image,
        line,
        font: bodyFont,
        x: addressIndent,
        y: currentY,
        color: whiteTextColor,
      );
      currentY += lineHeight;
    }

    // Draw date with icon
    img.fillRect(
      image,
      x1: padding,
      y1: currentY + 2,
      x2: padding + 12,
      y2: currentY + 12,
      color: accentColor,
    );

    img.drawString(
      image,
      'Date: $formattedDate',
      font: bodyFont,
      x: padding + 20,
      y: currentY,
      color: whiteTextColor,
    );
    currentY += lineHeight;

    // Draw time with icon
    img.fillRect(
      image,
      x1: padding,
      y1: currentY + 2,
      x2: padding + 12,
      y2: currentY + 12,
      color: accentColor,
    );

    img.drawString(
      image,
      'Time: $formattedTime',
      font: bodyFont,
      x: padding + 20,
      y: currentY,
      color: whiteTextColor,
    );

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // Encode with high quality
    await file.writeAsBytes(img.encodeJpg(image, quality: 95));

    return file;
  }

  static List<String> _splitAddress(String address, int maxCharsPerLine) {
    if (address.isEmpty) return ['Address not available'];

    final lines = <String>[];
    final words = address.split(' ');
    String currentLine = '';

    for (final word in words) {
      if (currentLine.isEmpty) {
        currentLine = word;
      } else if (('$currentLine  $word').length <= maxCharsPerLine) {
        currentLine += '  $word';
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }
    // Limit to maximum 3 lines
    if (lines.length > 3) {
      lines[2] = '${lines[2].substring(0, maxCharsPerLine - 3)}...';
      return lines.sublist(0, 3);
    }
    return lines;
  }
}
