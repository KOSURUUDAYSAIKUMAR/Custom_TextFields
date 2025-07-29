class UsernameValidator {
  static String? validateUsername(
    String? value, {
    RegExp? pattern,
    String? patternErrorMessage,
    String? requiredUsernameMessage, // New parameter for empty message
    bool preventConsecutiveSpaces = true,
    bool preventLeadingTrailingSpaces = true,
    required int minLength,
    required int maxLength,
  }) {
    if (value == null || value.isEmpty) {
      return requiredUsernameMessage ?? 'Username is required.';
    }

    // Apply trimming for validation before other checks if leading/trailing spaces are prevented
    String processedValue = value;
    if (preventLeadingTrailingSpaces) {
      processedValue = value.trim();
      if (processedValue != value) {
        return patternErrorMessage ??
            'Username cannot have leading or trailing spaces.';
      }
    }

    if (preventConsecutiveSpaces && processedValue.contains('  ')) {
      return patternErrorMessage ??
          'Username cannot contain consecutive spaces.';
    }

    if (processedValue.length < minLength) {
      return 'Username must be at least $minLength characters.';
    }
    if (processedValue.length > maxLength) {
      return 'Username cannot exceed $maxLength characters.';
    }
    if (value.contains(' ')) {
      return 'Username cannot contain spaces';
    }
    // Default pattern if none provided: alphanumeric, underscore, and dot
    final RegExp effectivePattern = pattern ?? RegExp(r'^[a-zA-Z0-9_.]+$');

    if (!effectivePattern.hasMatch(processedValue)) {
      return patternErrorMessage ?? 'Invalid username format.';
    }

    return null;
  }

  static String? Function(String?) createValidator({
    RegExp? pattern,
    String? patternErrorMessage,
    String? requiredUsernameMessage, // New parameter for empty message
    bool preventConsecutiveSpaces = true,
    bool preventLeadingTrailingSpaces = true,
    int minLength = 3, // Default values
    int maxLength = 20, // Default values
  }) {
    return (String? value) => validateUsername(
      value,
      pattern: pattern,
      patternErrorMessage: patternErrorMessage,
      requiredUsernameMessage: requiredUsernameMessage,
      preventConsecutiveSpaces: preventConsecutiveSpaces,
      preventLeadingTrailingSpaces: preventLeadingTrailingSpaces,
      minLength: minLength,
      maxLength: maxLength,
    );
  }
}
