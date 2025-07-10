class FullnameValidator {
  static final RegExp _defaultFullNameRegex = RegExp(r'^[a-zA-Z\s]{2,50}$');
  static RegExp? _customFullNameRegex;

  static void setCustomPattern(String pattern) {
    _customFullNameRegex = RegExp(pattern);
  }

  static void resetToDefaultPattern() {
    _customFullNameRegex = null;
  }

  static RegExp get activePattern =>
      _customFullNameRegex ?? _defaultFullNameRegex;

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }

    // Check for minimum length
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    // Check for numbers or special characters
    if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Name cannot contain numbers or special characters';
    }

    // Check for consecutive spaces
    if (value.contains('  ')) {
      return 'Name cannot contain consecutive spaces';
    }

    // Check for leading/trailing spaces
    if (value.trim() != value) {
      return 'Name cannot start or end with spaces';
    }

    // Check overall pattern
    if (!activePattern.hasMatch(value)) {
      return 'Please enter a valid name (letters and spaces only)';
    }

    return null;
  }

  static String? validateFullNameWithCustomMessage(
    String? value, {
    String errorMessage = 'Please enter a valid name',
    String requiredMessage = 'Full name is required',
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }

    // Check for minimum length
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    // Check for numbers or special characters
    if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Name cannot contain numbers or special characters';
    }

    // Check for consecutive spaces
    if (value.contains('  ')) {
      return 'Name cannot contain consecutive spaces';
    }

    // Check for leading/trailing spaces
    if (value.trim() != value) {
      return 'Name cannot start or end with spaces';
    }

    if (!activePattern.hasMatch(value)) {
      return errorMessage;
    }
    return null;
  }

  static bool isValid(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return activePattern.hasMatch(value);
  }
}
