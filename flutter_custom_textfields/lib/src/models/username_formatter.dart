import 'package:flutter/services.dart';

class UsernameInputFormatter extends TextInputFormatter {
  final RegExp? pattern;
  final bool preventConsecutiveSpaces;
  final bool preventLeadingTrailingSpaces; // New property

  UsernameInputFormatter({
    this.pattern,
    this.preventConsecutiveSpaces = true,
    this.preventLeadingTrailingSpaces = true, // Initialize new property
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final RegExp effectiveFormatterPattern =
        pattern ??
        RegExp(
          r'[a-zA-Z0-9_.]',
        ); // Default: alphanumeric, underscore, dot. Common for usernames.

    String newText = newValue.text;

    // 1. Prevent consecutive spaces (formatter applies this immediately)
    if (preventConsecutiveSpaces) {
      newText = newText.replaceAll(RegExp(r'\s\s+'), ' ');
    }

    // 2. Filter characters based on pattern
    final StringBuffer filteredText = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (effectiveFormatterPattern.hasMatch(newText[i])) {
        filteredText.write(newText[i]);
      }
    }
    newText = filteredText.toString();

    // 3. Prevent leading/trailing spaces (formatter applies this immediately)
    if (preventLeadingTrailingSpaces) {
      // If a space is at the start, and it's not the only char, or if it was just added at start
      if (newText.startsWith(' ') &&
          (newText.length > 1 || oldValue.text.isEmpty)) {
        newText = newText.trimLeft();
      }
      // If a space is at the end, and it wasn't there before
      if (newText.endsWith(' ') && !oldValue.text.endsWith(' ')) {
        newText = newText.trimRight();
      }
    }

    // Reconstruct TextEditingValue based on the filtered and trimmed text
    // Adjust cursor position if text changed
    if (newText != newValue.text) {
      // Calculate new selection offset based on changes
      int newOffset = newValue.selection.end;
      if (newOffset > newText.length) {
        newOffset = newText.length;
      }
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newOffset),
        composing: TextRange.empty,
      );
    }

    return newValue;
  }
}
