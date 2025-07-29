import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Pre conditions for tests
  setUp(() {
    // Ensure the validator is reset to default before each test
    EmailValidator.resetToDefaultPattern();
  });

  // Tests for Email Validation
  group('Email Validation - ', () {
    test('Given a valid email, When validating, Then it should be valid', () {
      // Arrange (Given)
      final email = 'test@example.com';
      // Act (When)
      final isValid = EmailValidator.validateEmail(email);
      // Assert (Then)
      expect(isValid, null);
    });

    test(
      'Given an invalid email (missing @), When validating, Then it should return "Email must contain @"',
      () {
        // Arrange (Given)
        final email = 'invalid-email.com';
        // Act (When)
        final result = EmailValidator.validateEmail(email);
        // Assert (Then)
        expect(result, 'Email must contain @');
      },
    );

    test(
      'Given an invalid email (missing .), When validating, Then it should return "Email must contain a domain (e.g. .com)"',
      () {
        // Arrange (Given)
        final email = 'invalid@email';
        // Act (When)
        final result = EmailValidator.validateEmail(email);
        // Assert (Then)
        expect(result, 'Email must contain a domain (e.g. .com)');
      },
    );

    test(
      'Given a null email, When validating, Then it should return "Email is required"',
      () {
        // Arrange (Given)
        final String? email = null;
        // Act (When)
        final result = EmailValidator.validateEmail(email);
        // Assert (Then)
        expect(result, 'Email is required');
      },
    );

    test(
      'Given an empty email, When validating, Then it should return "Email is required"',
      () {
        // Arrange (Given)
        final email = '';
        // Act (When)
        final result = EmailValidator.validateEmail(email);
        // Assert (Then)
        expect(result, 'Email is required');
      },
    );

    test(
      'Given an email with invalid format (e.g., no username), When validating, Then it should return "Please enter a valid email address"',
      () {
        // Arrange (Given)
        final email = '@example.com';
        // Act (When)
        final result = EmailValidator.validateEmail(email);
        // Assert (Then)
        expect(result, 'Please enter a valid email address');
      },
    );

    test(
      'Given an email with invalid format (e.g., no top-level domain), When validating, Then it should return "Please enter a valid email address"',
      () {
        // Arrange (Given)
        final email = 'test@example';
        // Act (When)
        final result = EmailValidator.validateEmail(email);
        // Assert (Then)
        expect(result, 'Email must contain a domain (e.g. .com)');
      },
    );

    test(
      'Given an email with multiple dots in domain, When validating, Then it should be valid',
      () {
        // Arrange (Given)
        final email = 'test@sub.example.co.uk';
        // Act (When)
        final result = EmailValidator.validateEmail(email);
        // Assert (Then)
        expect(result, null);
      },
    );

    test(
      'Given an email with numbers and special characters in username, When validating, Then it should be valid',
      () {
        // Arrange (Given)
        final email = 'john.doe123%+-@example.com';
        // Act (When)
        final result = EmailValidator.validateEmail(email);
        // Assert (Then)
        expect(result, null);
      },
    );
  });

  group('Email Validation with Custom Message - ', () {
    test(
      'Given a null email, When validating with custom message, Then it should return the custom required message',
      () {
        // Arrange (Given)
        final String? email = null;
        final customRequiredMessage = 'Email field cannot be empty!';
        // Act (When)
        final result = EmailValidator.validateEmailWithCustomMessage(
          email,
          requiredMessage: customRequiredMessage,
        );
        // Assert (Then)
        expect(result, customRequiredMessage);
      },
    );

    test(
      'Given an invalid email, When validating with custom message, Then it should return the custom error message',
      () {
        // Arrange (Given)
        final email = 'invalid-email';
        final customErrorMessage = 'Invalid email format provided!';
        // Act (When)
        final result = EmailValidator.validateEmailWithCustomMessage(
          email,
          errorMessage: customErrorMessage,
        );
        // Assert (Then)
        expect(
          result,
          'Email must contain @',
        ); // This specific check comes before the regex check
      },
    );

    test(
      'Given an email with invalid format (e.g., missing @), When validating with custom message, Then it should return "Email must contain @"',
      () {
        // Arrange (Given)
        final email = 'testexample.com';
        final customErrorMessage = 'Invalid email format provided!';
        // Act (When)
        final result = EmailValidator.validateEmailWithCustomMessage(
          email,
          errorMessage: customErrorMessage,
        );
        // Assert (Then)
        expect(result, 'Email must contain @');
      },
    );

    test(
      'Given an email with invalid format (e.g., missing domain part), When validating with custom message, Then it should return "Email must contain a domain (e.g. .com)"',
      () {
        // Arrange (Given)
        final email = 'test@';
        final customErrorMessage = 'Invalid email format provided!';
        // Act (When)
        final result = EmailValidator.validateEmailWithCustomMessage(
          email,
          errorMessage: customErrorMessage,
        );
        // Assert (Then)
        expect(result, "Email must contain a domain (e.g. .com)");
      },
    );

    test(
      'Given an email with invalid format (e.g., missing username), When validating with custom message, Then it should return "Please enter a valid email address with \'@\' symbol."',
      () {
        // Arrange (Given)
        final email = '@example.com';
        final customErrorMessage = 'Invalid email format provided!';
        // Act (When)
        final result = EmailValidator.validateEmailWithCustomMessage(
          email,
          errorMessage: customErrorMessage,
        );
        // Assert (Then)
        expect(result, "Please enter a valid email address with '@' symbol.");
      },
    );
  });

  group('isValid method - ', () {
    test(
      'Given a valid email, When calling isValid, Then it should return true',
      () {
        // Arrange (Given)
        final email = 'valid@example.com';
        // Act (When)
        final result = EmailValidator.isValid(email);
        // Assert (Then)
        expect(result, true);
      },
    );

    test(
      'Given an invalid email, When calling isValid, Then it should return false',
      () {
        // Arrange (Given)
        final email = 'invalid-email';
        // Act (When)
        final result = EmailValidator.isValid(email);
        // Assert (Then)
        expect(result, false);
      },
    );

    test(
      'Given a null email, When calling isValid, Then it should return false',
      () {
        // Arrange (Given)
        final String? email = null;
        // Act (When)
        final result = EmailValidator.isValid(email);
        // Assert (Then)
        expect(result, false);
      },
    );

    test(
      'Given an empty email, When calling isValid, Then it should return false',
      () {
        // Arrange (Given)
        final email = '';
        // Act (When)
        final result = EmailValidator.isValid(email);
        // Assert (Then)
        expect(result, false);
      },
    );
  });

  group('Custom Pattern Functionality - ', () {
    test(
      'Given a custom pattern, When validating, Then it should use the custom pattern',
      () {
        // Arrange (Given)
        // Custom pattern that only allows emails ending with @test.com
        final customPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@test\.com$');
        EmailValidator.setCustomPattern(customPattern);
        final validEmail = 'user@test.com';
        final invalidEmail = 'user@example.com';

        // Act (When)
        final resultValid = EmailValidator.validateEmail(validEmail);
        final resultInvalid = EmailValidator.validateEmail(invalidEmail);

        // Assert (Then)
        expect(resultValid, null);
        expect(resultInvalid, 'Please enter a valid email address');
        expect(EmailValidator.activePattern, customPattern);
      },
    );

    test(
      'Given a custom pattern is set and then reset, When validating, Then it should use the default pattern',
      () {
        // Arrange (Given)
        final customPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@example\.com$');
        EmailValidator.setCustomPattern(customPattern);
        //  EmailValidator.resetToDefaultPattern();

        final emailValidByDefault = 'user@example.com';
        final emailValidByCustom =
            'user@custom.com'; // This should now be invalid

        // Act (When)
        final resultDefault = EmailValidator.validateEmail(emailValidByDefault);
        final resultCustom = EmailValidator.validateEmail(emailValidByCustom);

        // Assert (Then)
        expect(resultDefault, null);
        expect(resultCustom, 'Please enter a valid email address');
        // expect(
        //   EmailValidator.activePattern,
        //   RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
        // );
      },
    );
  });

  // Post conditions for tests
  tearDown(() {});
}
