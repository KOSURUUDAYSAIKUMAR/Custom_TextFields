import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    // Reset to default pattern before each test to ensure isolation
    PasswordValidator.resetToDefaultPattern(
      minPasswordLength: 6,
      maxPasswordLength: 10,
    );
  });

  group('Password Validation - Default Pattern (Min 6, Max 10, U/L/D/S) - ', () {
    test('Given a valid password, When validating, Then it should be null', () {
      final password = 'P@ssw0rd1';
      final result = PasswordValidator.validatePassword(password);
      expect(result, null);
    });

    test(
      'Given a null password, When validating, Then it should return "Password is required."',
      () {
        final String? password = null;
        final result = PasswordValidator.validatePassword(password);
        expect(result, 'Password is required.');
      },
    );

    test(
      'Given an empty password, When validating, Then it should return "Password is required."',
      () {
        final password = '';
        final result = PasswordValidator.validatePassword(password);
        expect(result, 'Password is required.');
      },
    );

    test(
      'Given a password shorter than minLength (6), Then it should return length error',
      () {
        final password = 'P@ss1'; // 5 chars
        final result = PasswordValidator.validatePassword(
          password,
          minPasswordLength: 6,
        );
        expect(result, 'Password must be at least 6 characters long.');
      },
    );

    test(
      'Given a password longer than maxLength (10), When validating, Then it should return length error',
      () {
        final password = 'P@ssw0rd123'; // 11 chars
        final result = PasswordValidator.validatePassword(
          password,
          minPasswordLength: 5,
          maxPasswordLength: 10,
        );
        expect(result, 'Password cannot exceed 10 characters.');
      },
    );

    test(
      'Given a password without an uppercase letter, When validating, Then it should return uppercase error',
      () {
        final password = 'p@ssw0rd1';
        final result = PasswordValidator.validatePassword(password);
        expect(result, 'Password must contain at least one uppercase letter.');
      },
    );

    test(
      'Given a password without a lowercase letter, Then it should return lowercase error',
      () {
        final password = 'P@SSW0RD1';
        final result = PasswordValidator.validatePassword(password);
        expect(result, 'Password must contain at least one lowercase letter.');
      },
    );

    test(
      'Given a password without a number, Then it should return number error',
      () {
        final password = 'P@ssword!';
        final result = PasswordValidator.validatePassword(password);
        expect(result, 'Password must contain at least one number.');
      },
    );

    test(
      'Given a password without a special character, when validating, Then it should return special character error',
      () {
        final password = 'Password1';
        final result = PasswordValidator.validatePassword(
          password,
          maxPasswordLength: 9,
        );
        expect(
          result,
          'Password must contain at least one special character: ',
        );
      },
    );

    test(
      'Given a password with a forbidden special character, When validating, Then it should return forbidden special character error',
      () {
        final customPattern = RegExp(
          r'^[a-zA-Z0-9!@#\$%^&*()_+{}\[\]:;<>,.?~\\-]{8,20}$',
        );
        PasswordValidator.setCustomPattern(customPattern);
        final password = 'P@ssw0rd1`';
        final result = PasswordValidator.validatePassword(password);
        final expected =
            r'Only these special characters are allowed: !@#$%^&*()_+{}\[:;<>,.?~-';

        expect(result, expected);
      },
    );
  });

  group('Password Validation with Custom Messages - ', () {
    test(
      'Given a null password, When validating with custom required message, Then it should return custom message',
      () {
        final String? password = null;
        final customMessage = 'Please enter your password here.';
        final result = PasswordValidator.validatePassword(
          password,
          requiredPasswordMessage: customMessage,
        );
        expect(result, customMessage);
      },
    );

    test(
      'Given a too short password, When validating with custom invalid message, Then it should return custom message',
      () {
        final password = 'P@s1'; // 4 chars
        final customMessage = 'Password is too short, please make it longer.';
        final result = PasswordValidator.validatePassword(
          password,
          invalidPasswordMessage: customMessage,
          minPasswordLength: 6,
        );
        expect(result, customMessage);
      },
    );

    test(
      'Given a password missing uppercase, When validating with custom invalid message, Then it should return custom message',
      () {
        final password = 'p@ssword1';
        final customMessage = 'Password needs an uppercase letter, try again.';
        final result = PasswordValidator.validatePassword(
          password,
          invalidPasswordMessage: customMessage,
        );
        expect(result, customMessage);
      },
    );
  });

  group('Password Validation - Custom Pattern Functionality - ', () {
    test(
      'Given a custom pattern (min 5, max 8, no special chars), When validating, Then it should use it',
      () {
        // Custom pattern: at least one letter, at least one number, 5-8 chars, no special chars
        final RegExp customPattern = RegExp(
          r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{5,8}$',
        );
        PasswordValidator.setCustomPattern(customPattern);

        final validPassword = 'Abcde12'; // 7 chars, letter, number, no special
        final invalidTooLong = 'Abcde1234'; // 9 chars
        final invalidSpecialChar = 'Abcde!23'; // has special char
        final invalidNoNumber = 'Abcdefg'; // no number

        expect(
          PasswordValidator.validatePassword(
            validPassword,
            minPasswordLength: 5,
            maxPasswordLength: 8,
          ),
          null,
        );
        expect(
          PasswordValidator.validatePassword(
            invalidTooLong,
            minPasswordLength: 5,
            maxPasswordLength: 8,
          ),
          'Password cannot exceed 8 characters.',
        );
        // Corrected expectation for a pattern that allows no special characters
        expect(
          PasswordValidator.validatePassword(
            invalidSpecialChar,
            minPasswordLength: 5,
            maxPasswordLength: 8,
          ),
          'Only these special characters are allowed: ',
        );
        expect(
          PasswordValidator.validatePassword(
            invalidNoNumber,
            minPasswordLength: 5,
            maxPasswordLength: 8,
          ),
          'Password must contain at least one number.',
        );
        expect(PasswordValidator.activePattern.pattern, customPattern.pattern);
      },
    );

    test(
      'Given a custom pattern is set and then reset, When validating, Then it should use the default pattern',
      () {
        // Set a very specific custom pattern
        final customPattern = RegExp(
          r'^(?=.*[X])X{5}$',
        ); // Must be exactly 5 'X's with one 'X' uppercase
        PasswordValidator.setCustomPattern(customPattern);

        // Reset to default
        PasswordValidator.resetToDefaultPattern(
          minPasswordLength: 6,
          maxPasswordLength: 10,
        );

        // Test with a password valid for the default pattern
        final passwordValidByDefault = 'P@ssw0rd1';
        // Test with a password that would have been valid for the custom pattern (but now isn't)
        final passwordValidByCustom = 'XXXXX';

        expect(
          PasswordValidator.validatePassword(
            passwordValidByDefault,
            minPasswordLength: 6,
            maxPasswordLength: 10,
          ),
          null,
        );
        expect(
          PasswordValidator.validatePassword(
            passwordValidByCustom,
            minPasswordLength: 6,
            maxPasswordLength: 10,
          ),
          'Password must be at least 6 characters long.',
        ); // Fails default rules
        // Reconstruct the expected default pattern string for comparison
        final expectedDefaultPattern =
            '^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)${PasswordValidatorLetters.specialCharacters}.{6,10}\$';
        expect(PasswordValidator.activePattern.pattern, expectedDefaultPattern);
      },
    );

    test(
      'Given resetToDefaultPattern with specific lengths, When validating, Then default pattern uses those lengths',
      () {
        PasswordValidator.resetToDefaultPattern(
          minPasswordLength: 8,
          maxPasswordLength: 12,
        );
        final passwordTooShort = 'P@ssw0r1'; // 8 chars, should be fine
        final passwordTooShortExpectedError = 'P@ssw0r'; // 7 chars
        final passwordTooLong = 'P@ssw0rd12345'; // 13 chars

        expect(
          PasswordValidator.validatePassword(
            passwordTooShort,
            minPasswordLength: 8,
            maxPasswordLength: 12,
          ),
          null,
        );
        expect(
          PasswordValidator.validatePassword(
            passwordTooShortExpectedError,
            minPasswordLength: 8,
            maxPasswordLength: 12,
          ),
          'Password must be at least 8 characters long.',
        );
        expect(
          PasswordValidator.validatePassword(
            passwordTooLong,
            minPasswordLength: 8,
            maxPasswordLength: 12,
          ),
          'Password cannot exceed 12 characters.',
        );
        // Reconstruct the expected pattern string for the specified lengths
        final expectedPatternForLengths =
            '^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)${PasswordValidatorLetters.specialCharacters}.{8,12}\$';
        expect(
          PasswordValidator.activePattern.pattern,
          expectedPatternForLengths,
        );
      },
    );
  });
}
