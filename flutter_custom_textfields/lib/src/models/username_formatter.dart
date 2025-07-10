import 'package:flutter/services.dart';

class UsernameInputFormatter extends TextInputFormatter {
  final RegExp allowedPattern;
  final bool preventConsecutiveSpaces;
  UsernameInputFormatter({
    RegExp? pattern,
    this.preventConsecutiveSpaces = true,
  }) : allowedPattern = pattern ?? RegExp(r'[A-Za-z0-9 ]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String filteredText = newValue.text
        .split('')
        .where((char) => allowedPattern.hasMatch(char))
        .join('');

    if (preventConsecutiveSpaces) {
      while (filteredText.contains('  ')) {
        filteredText = filteredText.replaceAll('  ', ' ');
      }
    }
    int selectionIndex = newValue.selection.end;
    int difference = newValue.text.length - filteredText.length;
    selectionIndex = selectionIndex - difference;
    if (selectionIndex < 0) {
      selectionIndex = 0;
    }
    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
