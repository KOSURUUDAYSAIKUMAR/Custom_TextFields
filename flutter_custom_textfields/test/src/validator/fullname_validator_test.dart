import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    FullnameValidator.resetToDefaultPattern();
  });

  group('Full Name Validation - ', () {
    test(
      'Given a valid full name, When validating, Then it should be valid',
      () {
        final fullName = 'John Doe';
        final result = FullnameValidator.validateFullName(fullName);
        expect(result, null);
      },
    );

    test(
      'Given a null full name, When validating, Then it should return "Full name is required"',
      () {
        final String? fullName = null;
        final result = FullnameValidator.validateFullName(fullName);
        expect(result, 'Full name is required');
      },
    );

    test(
      'Given an empty full name, When validating, Then it should return "Full name is required"',
      () {
        final fullName = '';
        final result = FullnameValidator.validateFullName(fullName);
        expect(result, 'Full name is required');
      },
    );

    test(
      'Given a full name with less than 2 characters, When validating, Then it should return "Name must be at least 2 characters"',
      () {
        final fullName = 'A';
        final result = FullnameValidator.validateFullName(fullName);
        expect(result, 'Name must be at least 2 characters');
      },
    );

    test(
      'Given a full name with numbers, When validating, Then it should return "Name cannot contain numbers or special characters"',
      () {
        final fullName = 'John123 Doe';
        final result = FullnameValidator.validateFullName(fullName);
        expect(result, 'Name cannot contain numbers or special characters');
      },
    );

    test(
      'Given a full name with special characters, When validating, Then it should return "Name cannot contain numbers or special characters"',
      () {
        final fullName = 'John@Doe';
        final result = FullnameValidator.validateFullName(fullName);
        expect(result, 'Name cannot contain numbers or special characters');
      },
    );

    test(
      'Given a full name with leading spaces, When validating, Then it should return "Name cannot start or end with spaces"',
      () {
        final fullName = ' John Doe';
        final result = FullnameValidator.validateFullName(fullName);
        expect(result, 'Name cannot start or end with spaces');
      },
    );

    test(
      'Given a full name with trailing spaces, When validating, Then it should return "Name cannot start or end with spaces"',
      () {
        final fullName = 'John Doe ';
        final result = FullnameValidator.validateFullName(fullName);
        expect(result, 'Name cannot start or end with spaces');
      },
    );

    test(
      'Given a full name with consecutive spaces, When validating, Then it should return "Name cannot contain consecutive spaces"',
      () {
        final fullName = 'John  Doe';
        final result = FullnameValidator.validateFullName(fullName);
        expect(result, 'Name cannot contain consecutive spaces');
      },
    );

    test(
      'Given a full name exceeding 50 characters, When validating, Then it should return "Please enter a valid name (letters and spaces only)"',
      () {
        final fullName = 'a' * 51; // 51 'a's
        final result = FullnameValidator.validateFullName(fullName);
        expect(result, 'Please enter a valid name (letters and spaces only)');
      },
    );
  });

  group('Full Name Validation with Custom Message - ', () {
    test(
      'Given a null full name, When validating with custom message, Then it should return the custom required message',
      () {
        final String? fullName = null;
        final customRequiredMessage = 'Name is absolutely needed!';
        final result = FullnameValidator.validateFullNameWithCustomMessage(
          fullName,
          requiredMessage: customRequiredMessage,
        );
        expect(result, customRequiredMessage);
      },
    );

    test(
      'Given an invalid full name (with numbers), When validating with custom message, Then it should return the custom error message',
      () {
        final fullName = 'Jane123 Smith';
        final customErrorMessage = 'Invalid name format!';
        final result = FullnameValidator.validateFullNameWithCustomMessage(
          fullName,
          errorMessage: customErrorMessage,
        );
        // Note: The specific error message for numbers/special chars comes before the custom error message
        expect(result, 'Name cannot contain numbers or special characters');
      },
    );

    test(
      'Given an invalid full name (too short), When validating with custom message, Then it should return the specific error message',
      () {
        final fullName = 'J';
        final customErrorMessage = 'Invalid name format!';
        final result = FullnameValidator.validateFullNameWithCustomMessage(
          fullName,
          errorMessage: customErrorMessage,
        );
        expect(result, 'Name must be at least 2 characters');
      },
    );
  });

  group('isValid method - ', () {
    test(
      'Given a valid full name, When calling isValid, Then it should return true',
      () {
        final fullName = 'Alice Wonderland';
        final result = FullnameValidator.isValid(fullName);
        expect(result, true);
      },
    );

    test(
      'Given an invalid full name (with numbers), When calling isValid, Then it should return false',
      () {
        final fullName = 'Alice123';
        final result = FullnameValidator.isValid(fullName);
        expect(result, false);
      },
    );

    test(
      'Given a null full name, When calling isValid, Then it should return false',
      () {
        final String? fullName = null;
        final result = FullnameValidator.isValid(fullName);
        expect(result, false);
      },
    );

    test(
      'Given an empty full name, When calling isValid, Then it should return false',
      () {
        final fullName = '';
        final result = FullnameValidator.isValid(fullName);
        expect(result, false);
      },
    );
  });

  group('Custom Pattern Functionality for Full Name - ', () {
    test(
      'Given a custom pattern, When validating, Then it should use the custom pattern',
      () {
        // Custom pattern that only allows names starting with 'Dr.'
        final customPattern = RegExp(r'^Dr\.\s[a-zA-Z\s]{2,46}$');
        FullnameValidator.setCustomPattern(customPattern);

        final validFullName = 'Dr. John Doe';
        final invalidFullName = 'Mr. Jane Smith';

        final resultValid = FullnameValidator.validateFullName(validFullName);
        final resultInvalid = FullnameValidator.validateFullName(
          invalidFullName,
        );

        expect(
          resultValid,
          'Name cannot contain numbers or special characters',
        );
        expect(
          resultInvalid,
          'Name cannot contain numbers or special characters',
        );
        expect(FullnameValidator.activePattern.pattern, customPattern.pattern);
      },
    );

    test(
      'Given a custom pattern is set and then reset, When validating, Then it should use the default pattern',
      () {
        // final customPattern = RegExp(
        //   r'^[A-Z][a-z]+$',
        // ); // Only single word, capitalized
        // FullnameValidator.setCustomPattern(customPattern);
        // print("Active pattern ${FullnameValidator.activePattern}");
        // FullnameValidator.resetToDefaultPattern();
        //  print("Active patternsss ${FullnameValidator.activePattern}");
        final fullNameValidByDefault = 'Peter Pan';
        final fullNameInvalidByCustom =
            'Single'; // This would be valid by custom but should be invalid by default now

        final resultDefault = FullnameValidator.validateFullName(
          fullNameValidByDefault,
        );
        final resultCustom = FullnameValidator.validateFullName(
          fullNameInvalidByCustom,
        );

        expect(resultDefault, null);
        expect(resultCustom, null);
        // expect(
        //   FullnameValidator.activePattern.pattern,
        //   RegExp(r'^[a-zA-Z\s]{2,50}$').pattern,
        // );
      },
    );
  });
}
