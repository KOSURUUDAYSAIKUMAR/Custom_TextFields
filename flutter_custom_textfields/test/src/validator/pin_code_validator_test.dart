import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PinCodeValidator', () {
    // Test case 1: Valid PIN codes
    test(
      'should return null for valid 6-digit PIN codes (not starting with 0)',
      () {
        expect(PinCodeValidator.validate('123456'), null);
        expect(PinCodeValidator.validate('987654'), null);
        expect(PinCodeValidator.validate('500001'), null);
      },
    );

    // Test case 2: Empty or null PIN code
    test('should return "PIN code is required." for empty or null value', () {
      expect(PinCodeValidator.validate(null), 'PIN code is required.');
      expect(PinCodeValidator.validate(''), 'PIN code is required.');
    });

    // Test case 3: Incorrect length (less than 6 digits)
    test(
      'should return "PIN code must be exactly 6 digits." for less than 6 digits',
      () {
        expect(
          PinCodeValidator.validate('12345'),
          'PIN code must be exactly 6 digits.',
        );
        expect(
          PinCodeValidator.validate('1'),
          'PIN code must be exactly 6 digits.',
        );
      },
    );

    // Test case 4: Incorrect length (more than 6 digits)
    test(
      'should return "PIN code must be exactly 6 digits." for more than 6 digits',
      () {
        expect(
          PinCodeValidator.validate('1234567'),
          'PIN code must be exactly 6 digits.',
        );
        expect(
          PinCodeValidator.validate('1234567890'),
          'PIN code must be exactly 6 digits.',
        );
      },
    );

    // Test case 5: PIN code starting with 0 (invalid Indian PIN code)
    test(
      'should return "Enter a valid Indian PIN code (e.g., first digit 1-9)." for PIN starting with 0',
      () {
        expect(
          PinCodeValidator.validate('012345'),
          'Enter a valid Indian PIN code (e.g., first digit 1-9).',
        );
        expect(
          PinCodeValidator.validate('000000'),
          'Enter a valid Indian PIN code (e.g., first digit 1-9).',
        );
      },
    );

    // Test case 6: PIN code with non-digit characters
    test(
      'should return "Enter a valid Indian PIN code (e.g., first digit 1-9)." for non-digit characters',
      () {
        expect(
          PinCodeValidator.validate('123AB6'),
          'Enter a valid Indian PIN code (e.g., first digit 1-9).',
        );
        expect(
          PinCodeValidator.validate('123 45'),
          'Enter a valid Indian PIN code (e.g., first digit 1-9).',
        );
        expect(
          PinCodeValidator.validate('123.45'),
          'Enter a valid Indian PIN code (e.g., first digit 1-9).',
        );
        expect(
          PinCodeValidator.validate('ABCDEF'),
          'Enter a valid Indian PIN code (e.g., first digit 1-9).',
        );
      },
    );

    // Test case 7: Custom invalidPinCodeMessage
    test('should return custom invalid message for invalid PIN code', () {
      const customMessage = 'Invalid PIN format!';
      expect(
        PinCodeValidator.validate(
          '012345',
          invalidPinCodeMessage: customMessage,
        ),
        customMessage,
      );
      expect(
        PinCodeValidator.validate(
          '123A56',
          invalidPinCodeMessage: customMessage,
        ),
        customMessage,
      );
      expect(
        PinCodeValidator.validate('123', invalidPinCodeMessage: customMessage),
        customMessage,
      );
    });

    // Test case 8: Custom requiredPinCodeMessage
    test('should return custom required message for empty PIN code', () {
      const customMessage = 'Please enter PIN code.';
      expect(
        PinCodeValidator.validate(null, requiredPinCodeMessage: customMessage),
        customMessage,
      );
      expect(
        PinCodeValidator.validate('', requiredPinCodeMessage: customMessage),
        customMessage,
      );
    });
  });
}
