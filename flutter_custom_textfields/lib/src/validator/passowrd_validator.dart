/// A utility class for validating passwords based on specific criteria.
class PasswordValidator {
  // Default regex pattern for password validation.
  // This pattern ensures:
  // ^                - Start of the string.
  // (?=.*[A-Z])      - At least one uppercase letter.
  // (?=.*[a-z])      - At least one lowercase letter.
  // (?=.*\d)         - At least one digit.
  // (?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\-]) - At least one special character.
  //                  (Common special characters included. You can customize this set).
  // .{6,10}          - Minimum 6 and maximum 10 characters in total.
  // $                - End of the string.

  static const String _defaultRegexPattern =
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)' +
      PasswordValidatorLetters.specialCharacters +
      r'.{6,10}$';

  /// Validates a given password against a set of rules.
  ///
  /// [password] The password string to validate.
  /// [customRegexPattern] An optional custom regex pattern to use for validation.
  ///                      If null or empty, the default regex pattern will be used.
  ///
  /// Returns a [String] containing an error message if the password is invalid,
  /// otherwise returns `null` if the password is valid.

  static String? validatePassword(
    String? password, {
    String? customRegexPattern,
    String? invalidPasswordMessage,
    String? requiredPasswordMessage,
  }) {
    // 1. Check for empty input
    if (password == null || password.isEmpty) {
      return invalidPasswordMessage ?? 'Password cannot be empty.';
    }
    // Determine which regex pattern to use
    String effectiveRegexPattern = _defaultRegexPattern;
    if (customRegexPattern != null && customRegexPattern.isNotEmpty) {
      try {
        // Attempt to create a RegExp object to validate the custom pattern
        RegExp(customRegexPattern);
        effectiveRegexPattern = customRegexPattern;
      } catch (e) {
        // If custom pattern is invalid, log error and fall back to default
        print(
          'Warning: Invalid custom regex pattern provided. Using default. Error: $e',
        );
        effectiveRegexPattern = _defaultRegexPattern;
      }
    }
    // Create a RegExp object from the effective pattern
    final RegExp passwordRegExp = RegExp(effectiveRegexPattern);
    // 2. Check if the password matches the regex pattern
    if (!passwordRegExp.hasMatch(password)) {
      // Provide specific error messages based on common failures if not matching the full regex
      if (password.isEmpty) {
        return requiredPasswordMessage ?? 'Password is required.';
      }
      if (password.length < 6) {
        return invalidPasswordMessage ??
            'Password must be at least 6 characters long.';
      }
      if (password.length > 10) {
        return invalidPasswordMessage ??
            'Password cannot exceed 10 characters.';
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
      if (!RegExp(
        PasswordValidatorLetters.specialCharacters,
      ).hasMatch(password)) {
        return invalidPasswordMessage ??
            'Password must contain at least one special character.';
      }
      // Fallback generic error if none of the specific checks caught it (unlikely with a comprehensive regex)
      return invalidPasswordMessage ??
          'Password does not meet all requirements (e.g., length, uppercase, lowercase, number, special character).';
    }
    // If all checks pass, the password is valid
    return null;
  }
}

// // --- Example Usage (for demonstration, not part of the class) ---
// void main() {
//   final validator = PasswordValidator();

//   print('--- Testing with Default Regex ---');
//   print(
//     'Valid password (P@ssw0rd1): ${validator.validatePassword('P@ssw0rd1')}',
//   ); // Should be null
//   print(
//     'Too short (P@ss1): ${validator.validatePassword('P@ss1')}',
//   ); // Should return error
//   print(
//     'Too long (P@ssword12345): ${validator.validatePassword('P@ssword12345')}',
//   ); // Should return error
//   print(
//     'No uppercase (p@ssw0rd1): ${validator.validatePassword('p@ssw0rd1')}',
//   ); // Should return error
//   print(
//     'No lowercase (P@SSW0RD1): ${validator.validatePassword('P@SSW0RD1')}',
//   ); // Should return error
//   print(
//     'No number (P@ssword!): ${validator.validatePassword('P@ssword!')}',
//   ); // Should return error
//   print(
//     'No special char (Password1): ${validator.validatePassword('Password1')}',
//   ); // Should return error
//   print(
//     'Empty password: ${validator.validatePassword('')}',
//   ); // Should return error

//   print(
//     '\n--- Testing with Custom Regex (e.g., min 5, max 8, only letters and numbers) ---',
//   );
//   // Custom regex: at least one letter, at least one number, 5-8 chars, no special chars
//   final String customPattern = r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{5,8}$';
//   print(
//     'Valid custom (Abcde12): ${validator.validatePassword('Abcde12', customRegexPattern: customPattern)}',
//   ); // Should be null
//   print(
//     'Invalid custom (Abcde12345): ${validator.validatePassword('Abcde12345', customRegexPattern: customPattern)}',
//   ); // Should return error (too long)
//   print(
//     'Invalid custom (Abc!1): ${validator.validatePassword('Abc!1', customRegexPattern: customPattern)}',
//   ); // Should return error (special char not allowed)
//   print(
//     'Invalid custom (abcde): ${validator.validatePassword('abcde', customRegexPattern: customPattern)}',
//   ); // Should return error (no number)

//   print(
//     '\n--- Testing with Invalid Custom Regex (should fall back to default) ---',
//   );
//   final String invalidCustomPattern = r'([A-Z]'; // Malformed regex
//   print(
//     'Invalid custom regex test (P@ssw0rd1): ${validator.validatePassword('P@ssw0rd1', customRegexPattern: invalidCustomPattern)}',
//   ); // Should be null (using default)
// }

class PasswordValidatorLetters {
  static const String specialCharacters =
      r'(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\-])';
}
