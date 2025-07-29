class EmailValidator {
  static final RegExp _defaultEmailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static RegExp? _customEmailRegex;

  static void setCustomPattern(RegExp pattern) {
    _customEmailRegex = pattern;
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
    if (!value.contains('@')) {
      return 'Email must contain @';
    }
    if (!value.contains('.')) {
      return 'Email must contain a domain (e.g. .com)';
    }
    final parts = value.split('@');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
      return "Please enter a valid email address with '@' symbol.";
    }
    final domainParts = parts[1].split('.');
    if (domainParts.length < 2 || domainParts.any((part) => part.isEmpty)) {
      return "Please enter a valid email domain.";
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
