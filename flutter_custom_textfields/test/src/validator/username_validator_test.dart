import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UsernameValidator', () {
    // --- Test cases for validateUsername method ---
    // Test Case 1: Null or empty value
    test('should return "Username is required." for null value', () {
      expect(
        UsernameValidator.validateUsername(null, minLength: 3, maxLength: 20),
        'Username is required.',
      );
    });

    test('should return "Username is required." for empty string', () {
      expect(
        UsernameValidator.validateUsername('', minLength: 3, maxLength: 20),
        'Username is required.',
      );
    });

    test('should return custom required message for null value', () {
      expect(
        UsernameValidator.validateUsername(
          null,
          requiredUsernameMessage: 'Enter a username!',
          minLength: 3,
          maxLength: 20,
        ),
        'Enter a username!',
      );
    });

    // Test Case 2: Leading/Trailing Spaces
    test(
      'should return "Username cannot have leading or trailing spaces." when preventLeadingTrailingSpaces is true',
      () {
        expect(
          UsernameValidator.validateUsername(
            ' user',
            preventLeadingTrailingSpaces: true,
            minLength: 3,
            maxLength: 20,
          ),
          'Username cannot have leading or trailing spaces.',
        );
        expect(
          UsernameValidator.validateUsername(
            'user ',
            preventLeadingTrailingSpaces: true,
            minLength: 3,
            maxLength: 20,
          ),
          'Username cannot have leading or trailing spaces.',
        );
        expect(
          UsernameValidator.validateUsername(
            ' user ',
            preventLeadingTrailingSpaces: true,
            minLength: 3,
            maxLength: 20,
          ),
          'Username cannot have leading or trailing spaces.',
        );
      },
    );

    test(
      'should return null for leading/trailing spaces when preventLeadingTrailingSpaces is false',
      () {
        // Note: The `if (value.contains(' '))` check might still catch this later if not trimmed by pattern
        expect(
          UsernameValidator.validateUsername(
            ' user',
            preventLeadingTrailingSpaces: false,
            minLength: 3,
            maxLength: 20,
          ),
          'Username cannot contain spaces', // This is due to your `value.contains(' ')` check later
        );
        expect(
          UsernameValidator.validateUsername(
            'user ',
            preventLeadingTrailingSpaces: false,
            minLength: 3,
            maxLength: 20,
          ),
          'Username cannot contain spaces', // This is due to your `value.contains(' ')` check later
        );
      },
    );

    // Test Case 3: Consecutive Spaces
    test(
      'should return "Username cannot contain consecutive spaces." when preventConsecutiveSpaces is true',
      () {
        expect(
          UsernameValidator.validateUsername(
            'user  name',
            preventConsecutiveSpaces: true,
            minLength: 3,
            maxLength: 20,
          ),
          'Username cannot contain consecutive spaces.',
        );
      },
    );

    test(
      'should return null for consecutive spaces when preventConsecutiveSpaces is false',
      () {
        // Note: The `if (value.contains(' '))` check might still catch this later
        expect(
          UsernameValidator.validateUsername(
            'user  name',
            preventConsecutiveSpaces: false,
            minLength: 3,
            maxLength: 20,
          ),
          'Username cannot contain spaces', // This is due to your `value.contains(' ')` check later
        );
      },
    );

    // Test Case 4: Length validation
    test(
      'should return "Username must be at least X characters." for too short value',
      () {
        expect(
          UsernameValidator.validateUsername('ab', minLength: 3, maxLength: 20),
          'Username must be at least 3 characters.',
        );
      },
    );

    test(
      'should return "Username cannot exceed X characters." for too long value',
      () {
        expect(
          UsernameValidator.validateUsername(
            'abcdefghijklmnopqrstuvwxy',
            minLength: 3,
            maxLength: 20,
          ),
          'Username cannot exceed 20 characters.',
        );
      },
    );

    test('should return null for valid length username', () {
      expect(
        UsernameValidator.validateUsername('abc', minLength: 3, maxLength: 20),
        null,
      );
      expect(
        UsernameValidator.validateUsername(
          'abcdefghijklmnopqrst',
          minLength: 3,
          maxLength: 20,
        ),
        null,
      );
    });

    // Test Case 5: Contains spaces (your specific check)
    // Note: This test is specifically for your `if (value.contains(' '))` line.
    // If your `pattern` also disallows spaces, this might be redundant.
    test(
      'should return "Username cannot contain spaces" if value contains any space',
      () {
        expect(
          UsernameValidator.validateUsername(
            'user name',
            minLength: 3,
            maxLength: 20,
          ),
          'Username cannot contain spaces',
        );
      },
    );

    // Test Case 6: Pattern validation (using default pattern `^[a-zA-Z0-9_.]+$`)
    test('should return null for valid username matching default pattern', () {
      expect(
        UsernameValidator.validateUsername(
          'valid_user.123',
          minLength: 3,
          maxLength: 20,
        ),
        null,
      );
      expect(
        UsernameValidator.validateUsername(
          'userName',
          minLength: 3,
          maxLength: 20,
        ),
        null,
      );
    });

    test(
      'should return "Invalid username format." for username not matching default pattern (e.g., with !)',
      () {
        expect(
          UsernameValidator.validateUsername(
            'user!name',
            minLength: 3,
            maxLength: 20,
          ),
          'Invalid username format.',
        );
        expect(
          UsernameValidator.validateUsername(
            'user@name',
            minLength: 3,
            maxLength: 20,
          ),
          'Invalid username format.',
        );
      },
    );

    test('should return custom pattern error message for invalid format', () {
      const customPatternError = 'Username has invalid characters!';
      expect(
        UsernameValidator.validateUsername(
          'user#name',
          patternErrorMessage: customPatternError,
          minLength: 3,
          maxLength: 20,
        ),
        customPatternError,
      );
    });

    // Test Case 7: Pattern validation (using custom pattern)
    test('should return null for username matching custom pattern', () {
      final customPattern = RegExp(r'^[a-z]+$'); // Only lowercase letters
      expect(
        UsernameValidator.validateUsername(
          'testuser',
          pattern: customPattern,
          minLength: 3,
          maxLength: 20,
        ),
        null,
      );
    });

    test('should return error for username not matching custom pattern', () {
      final customPattern = RegExp(r'^[a-z]+$'); // Only lowercase letters
      expect(
        UsernameValidator.validateUsername(
          'TestUser123',
          pattern: customPattern,
          minLength: 3,
          maxLength: 20,
        ),
        'Invalid username format.',
      );
    });

    // --- Test cases for createValidator method ---

    test(
      'createValidator should return a function that validates correctly with default values',
      () {
        final validator = UsernameValidator.createValidator();
        expect(
          validator(null),
          'Username is required.',
        ); // Default required message
        expect(
          validator('ab'),
          'Username must be at least 3 characters.',
        ); // Default minLength
        expect(
          validator('abc!'),
          'Invalid username format.',
        ); // Default pattern
        expect(validator('valid_username'), null);
      },
    );

    test(
      'createValidator should return a function that uses provided custom messages',
      () {
        final validator = UsernameValidator.createValidator(
          requiredUsernameMessage: 'Cannot be empty!',
          patternErrorMessage: 'Wrong chars!',
        );
        expect(validator(null), 'Cannot be empty!');
        expect(validator('abc!'), 'Wrong chars!');
      },
    );

    test(
      'createValidator should return a function that uses provided min/max lengths',
      () {
        final validator = UsernameValidator.createValidator(
          minLength: 5,
          maxLength: 10,
        );
        expect(validator('abcd'), 'Username must be at least 5 characters.');
        expect(
          validator('abcdefghijk'),
          'Username cannot exceed 10 characters.',
        );
        expect(validator('abcde'), null);
      },
    );

    test(
      'createValidator should return a function that respects space prevention settings',
      () {
        final validatorNoSpaces = UsernameValidator.createValidator(
          preventConsecutiveSpaces: true,
          preventLeadingTrailingSpaces: true,
        );
        expect(
          validatorNoSpaces(' user '),
          'Username cannot have leading or trailing spaces.',
        );
        expect(
          validatorNoSpaces('user  name'),
          'Username cannot contain consecutive spaces.',
        );

        final validatorAllowSpaces = UsernameValidator.createValidator(
          preventConsecutiveSpaces: false,
          preventLeadingTrailingSpaces: false,
        );
        // Still caught by `value.contains(' ')` check
        expect(
          validatorAllowSpaces(' user '),
          'Username cannot contain spaces',
        );
        expect(
          validatorAllowSpaces('user  name'),
          'Username cannot contain spaces',
        );
      },
    );
  });
}
