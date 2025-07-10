class TextAreaValidator {
  static String? validate(
    String? value, {
    required int maxLength,
    String? emptyMessage,
    String? lengthMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'This field cannot be empty.';
    }
    if (value.length > maxLength) {
      return lengthMessage ?? 'Maximum $maxLength characters allowed.';
    }
    return null;
  }
}
