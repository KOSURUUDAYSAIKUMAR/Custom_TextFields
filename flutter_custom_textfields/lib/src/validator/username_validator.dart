class UsernameValidator {
  static final RegExp defaultPattern = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  static String? validateUsername(
    String? value, {
    RegExp? pattern,
    String? patternErrorMessage,
    bool preventConsecutiveSpaces = true,
    bool preventLeadingTrailingSpaces = true,
  }) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    // Check minimum length
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    // Check maximum length
    if (value.length > 20) {
      return 'Username cannot exceed 20 characters';
    }

    // Check for spaces
    if (value.contains(' ')) {
      return 'Username cannot contain spaces';
    }

    // Check for special characters
    if (RegExp(r'[!@#$%^&*()+\-=\[\]{};:"\\|,.<>/?]').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscore';
    }

    final RegExp validCharsPattern = pattern ?? defaultPattern;
    if (!validCharsPattern.hasMatch(value)) {
      return patternErrorMessage ??
          'Username must be 3-20 characters long and can only contain letters, numbers, and underscore';
    }

    return null;
  }

  static String? Function(String?) createValidator({
    RegExp? pattern,
    String? patternErrorMessage,
    bool preventConsecutiveSpaces = true,
    bool preventLeadingTrailingSpaces = true,
  }) {
    return (String? value) => validateUsername(
      value,
      pattern: pattern,
      patternErrorMessage: patternErrorMessage,
      preventConsecutiveSpaces: preventConsecutiveSpaces,
      preventLeadingTrailingSpaces: preventLeadingTrailingSpaces,
    );
  }
}
