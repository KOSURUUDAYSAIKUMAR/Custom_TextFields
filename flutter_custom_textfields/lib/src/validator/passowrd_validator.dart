class PasswordValidator {
  static RegExp? _customRegexPattern;

  static RegExp _generateDefaultRegexPattern(int minLength, int maxLength) {
    final pattern =
        '^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)'
        '${PasswordValidatorLetters.specialCharacters}'
        '.{$minLength,$maxLength}\$';

    return RegExp(pattern);
  }

  static void setCustomPattern(RegExp? pattern) {
    _customRegexPattern = pattern;
  }

  static void resetToDefaultPattern({
    int? minPasswordLength,
    int? maxPasswordLength,
  }) {
    _customRegexPattern = _generateDefaultRegexPattern(
      minPasswordLength!,
      maxPasswordLength!,
    );
  }

  static RegExp get activePattern {
    return _customRegexPattern ?? _generateDefaultRegexPattern(6, 10);
  }

  /// Validates a given password against a set of rules.
  ///
  /// [password] The password string to validate.
  /// [invalidPasswordMessage] Optional message for invalid password format.
  /// [requiredPasswordMessage] Optional message for empty password.
  /// [minPasswordLength] The minimum allowed password length.
  /// [maxPasswordLength] The maximum allowed password length.
  ///
  /// Returns a [String] containing an error message if the password is invalid,
  /// otherwise returns `null` if the password is valid.
  static String? validatePassword(
    String? password, {
    String? invalidPasswordMessage,
    String? requiredPasswordMessage,
    int? minPasswordLength = 6, // Use these for specific error messages
    int? maxPasswordLength = 10, // Use these for specific error messages
  }) {
    // 1. Check for empty input
    if (password == null || password.isEmpty) {
      return requiredPasswordMessage ?? 'Password is required.';
    }
    print(
      "!activePattern.hasMatch(password) ${!activePattern.hasMatch(password)}",
    );
    // Use the active pattern for validation
    if (!activePattern.hasMatch(password)) {
      // Provide specific error messages based on common failures if not matching the full regex
      if (password.length < minPasswordLength!) {
        return invalidPasswordMessage ??
            'Password must be at least $minPasswordLength characters long.';
      }
      if (password.length > maxPasswordLength!) {
        return invalidPasswordMessage ??
            'Password cannot exceed $maxPasswordLength characters.';
      }
      if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
        return invalidPasswordMessage ??
            'Password must contain at least one uppercase letter.';
      }
      if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
        return invalidPasswordMessage ??
            'Password must contain at least one lowercase letter.';
      }
      if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
        return invalidPasswordMessage ??
            'Password must contain at least one number.';
      }

      String allowedSpecialChars = _extractAllowedSpecialChars(
        activePattern.pattern,
      );

      if (allowedSpecialChars.isEmpty && _customRegexPattern == null) {
        allowedSpecialChars = '!@#\$%^&*()_+{}[]:;<>,.?~\\-';
      }
      print("allowed special characters $allowedSpecialChars");
      final forbiddenSpecialChars = _findForbiddenSpecialChars(
        password,
        allowedSpecialChars,
      );
      print("Forbidden characters $forbiddenSpecialChars");
      if (forbiddenSpecialChars.isNotEmpty) {
        return invalidPasswordMessage ??
            'Only these special characters are allowed: $allowedSpecialChars';
      }
      print(
        "Special characters contains ${!_containsAny(password, allowedSpecialChars)}",
      );
      if (!_containsAny(password, allowedSpecialChars)) {
        return invalidPasswordMessage ??
            'Password must contain at least one special character: $allowedSpecialChars';
      }
      // Fallback generic error if none of the specific checks caught it
      return invalidPasswordMessage ??
          'Password does not meet all requirements (e.g., length, uppercase, lowercase, number, special character).';
    }
    // If all checks pass, the password is valid
    return null;
  }

  // static String _extractAllowedSpecialChars(String pattern) {
  //   // Looks for a character class like [@$!%*?&] in the pattern
  //   final match = RegExp(r'\[([^\]]+)\]').firstMatch(pattern);
  //   if (match != null) {
  //     // Remove letters, digits, and dash, keep only special chars
  //     return match
  //         .group(1)!
  //         .replaceAll(RegExp(r'[a-zA-Z0-9\-]'), '')
  //         .replaceAll(' ', ''); // Remove spaces if any
  //   }
  //   return '@#\$%^&*()_+{}[]:;<>,.?~\\'; // Default fallback, no dash
  // }

  static String _extractAllowedSpecialChars(String pattern) {
    final match = RegExp(r'\[([^\]]+)\]').firstMatch(pattern);
    String chars = '';
    if (match != null) {
      chars = match.group(1)!;
      // Remove letters, digits, and spaces
      chars = chars.replaceAll(RegExp(r'[a-zA-Z0-9\s]'), '');
      // Unescape \$ and \\
      chars = chars.replaceAll(r'\$', r'$').replaceAll(r'\\', r'\\');
      // Remove unescaped dashes unless at end or escaped
      chars = chars.replaceAllMapped(
        RegExp(r'(?<!\\)-(?!$)'), // match dashes not at the end and not escaped
        (_) => '',
      );
      // Add characters that appear outside the []
      final extraMatch = RegExp(r'\]([:;<>,.\?~\\-]*)').firstMatch(pattern);
      if (extraMatch != null) {
        chars += extraMatch.group(1) ?? '';
      }
      // Remove duplicates while preserving order
      final seen = <String>{};
      chars = chars.split('').where((c) => seen.add(c)).join();
    }
    // If still empty or only dash, treat as "no special characters allowed"
    if (chars.trim().isEmpty || chars == '-') {
      return '';
    }
    return chars;
  }

  /// Helper to check if password contains any of the allowed special characters
  static bool _containsAny(String password, String allowedChars) {
    for (var c in allowedChars.split('')) {
      if (password.contains(c)) return true;
    }
    return false;
  }

  /// Helper to find forbidden special characters in password
  static String _findForbiddenSpecialChars(
    String password,
    String allowedChars,
  ) {
    // Find all non-alphanumeric characters in password
    final specials = password.replaceAll(RegExp(r'[a-zA-Z0-9]'), '');
    // Return any that are not in allowedChars
    return specials.split('').where((c) => !allowedChars.contains(c)).join();
  }
}

class PasswordValidatorLetters {
  // Define the special characters regex part once
  static const String specialCharacters =
      r'(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\-])';
}
