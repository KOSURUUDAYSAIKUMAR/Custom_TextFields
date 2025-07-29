import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextAreaValidator', () {
    const int maxLength = 10;
    const String defaultEmptyMessage = 'This field cannot be empty.';
    const String defaultLengthMessage =
        'Maximum $maxLength characters allowed.';

    test('should return null for valid input within maxLength', () {
      expect(TextAreaValidator.validate('hello', maxLength: maxLength), null);
      expect(
        TextAreaValidator.validate('1234567890', maxLength: maxLength),
        null,
      );
    });

    test('should return emptyMessage for null value', () {
      expect(
        TextAreaValidator.validate(null, maxLength: maxLength),
        defaultEmptyMessage,
      );
      expect(
        TextAreaValidator.validate(
          null,
          maxLength: maxLength,
          emptyMessage: 'Custom empty message',
        ),
        'Custom empty message',
      );
    });

    test('should return emptyMessage for empty string', () {
      expect(
        TextAreaValidator.validate('', maxLength: maxLength),
        defaultEmptyMessage,
      );
      expect(
        TextAreaValidator.validate(
          '',
          maxLength: maxLength,
          emptyMessage: 'Custom empty message',
        ),
        'Custom empty message',
      );
    });

    test('should return emptyMessage for string with only spaces', () {
      expect(
        TextAreaValidator.validate('   ', maxLength: maxLength),
        defaultEmptyMessage,
      );
      expect(
        TextAreaValidator.validate(
          '   ',
          maxLength: maxLength,
          emptyMessage: 'Custom empty message',
        ),
        'Custom empty message',
      );
    });

    test('should return lengthMessage for input exceeding maxLength', () {
      expect(
        TextAreaValidator.validate('this is too long', maxLength: maxLength),
        defaultLengthMessage,
      );
      expect(
        TextAreaValidator.validate(
          'this is too long',
          maxLength: maxLength,
          lengthMessage: 'Custom length message',
        ),
        'Custom length message',
      );
    });

    test(
      'should return correct message when maxLength is 0 and value is not empty',
      () {
        expect(
          TextAreaValidator.validate('a', maxLength: 0),
          'Maximum 0 characters allowed.',
        );
      },
    );

    test('should return null when maxLength is 0 and value is empty', () {
      expect(
        TextAreaValidator.validate('', maxLength: 0),
        'This field cannot be empty.',
      );
    });
  });
}
