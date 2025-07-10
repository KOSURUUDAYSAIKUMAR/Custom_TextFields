class EmailValidator {
  static final RegExp _defaultEmailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static RegExp? _customEmailRegex;

  static void setCustomPattern(String pattern) {
    _customEmailRegex = RegExp(pattern);
  }

  static void resetToDefaultPattern() {
    _customEmailRegex = null;
  }

  static RegExp get activePattern => _customEmailRegex ?? _defaultEmailRegex;

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Check for @ symbol
    if (!value.contains('@')) {
      return 'Email must contain @';
    }

    // Check for domain
    if (!value.contains('.')) {
      return 'Email must contain a domain (e.g. .com)';
    }

    // Check for valid format
    if (!activePattern.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validateEmailWithCustomMessage(
    String? value, {
    String errorMessage = 'Please enter a valid email',
    String requiredMessage = 'Email is required',
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }

    // Check for @ symbol
    if (!value.contains('@')) {
      return 'Email must contain @';
    }

    // Check for domain
    if (!value.contains('.')) {
      return 'Email must contain a domain (e.g. .com)';
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
