import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

void main() {
  group('PhoneValidator', () {
    // --- Test cases for validateForCountry method ---

    late PhoneValidator defaultPhoneValidator;
    late PhoneValidationConfig customConfig;

    setUp(() {
      defaultPhoneValidator = PhoneValidator.defaultValidator(); 
      customConfig = const PhoneValidationConfig(
        defaultCountryCode: '+91',
        countryValidationRules: {
          '+91': CountryValidationRule(
            regex: r'^[6-9]\d{9}$',
            errorMessage: 'Mobile number must start with 6, 7, 8, or 9 digits',
            minLength: 10,
            maxLength: 10,
          ),
          '+1': CountryValidationRule(
            regex: r'^\d{10}$',
            errorMessage: 'US/Canada numbers must be 10 digits',
            minLength: 10,
            maxLength: 10,
          ),
          '+65': CountryValidationRule(
            regex: r'^\d{8}$',
            errorMessage: 'Singapore numbers must be 8 digits',
            minLength: 8,
            maxLength: 8,
          ),
          '+44': CountryValidationRule(
            regex: r'^\d{10,11}$',
            errorMessage: 'UK numbers must be 10-11 digits',
            minLength: 10,
            maxLength: 11,
          ),
        },
        defaultValidationRule: CountryValidationRule(
          regex: r'^\d{7,15}$',
          errorMessage: 'Phone number must be between 7 and 15 digits',
          minLength: 7,
          maxLength: 15,
        ),
      );
    });

    // Test with default validator and IN rules
    test(
      'validateForCountry should return valid for a valid Indian number (default config)',
      () {
        final result = defaultPhoneValidator.validateForCountry(
          '9876543210',
          '+91',
        );
        expect(result.isValid, true);
        expect(result.errorMessage, null);
      },
    );

    test(
      'validateForCountry should return invalid for a short Indian number (default config)',
      () {
        final result = defaultPhoneValidator.validateForCountry(
          '987654321',
          '+91',
        );
        expect(result.isValid, false);
        expect(result.errorMessage, 'Phone number must be at least 10 digits');
      },
    );

    test(
      'validateForCountry should return invalid for a long Indian number (default config)',
      () {
        final result = defaultPhoneValidator.validateForCountry(
          '98765432101',
          '+91',
        );
        expect(result.isValid, false);
        expect(result.errorMessage, 'Phone number must be at most 10 digits');
      },
    );

    test(
      'validateForCountry should return invalid for an Indian number with wrong starting digit (default config)',
      () {
        final result = defaultPhoneValidator.validateForCountry(
          '5876543210',
          '+91',
        );
        expect(result.isValid, false);
        expect(
          result.errorMessage,
          'Mobile number must start with 6, 7, 8, or 9 digits',
        );
      },
    );

    test(
      'validateForCountry should return invalid for an Indian number with non-digits (default config)',
      () {
        final result = defaultPhoneValidator.validateForCountry(
          '98765A3210',
          '+91',
        );
        expect(result.isValid, false);
        expect(
          result.errorMessage,
          'Mobile number must start with 6, 7, 8, or 9 digits',
        );
      },
    );

    // Test with default validator and US rules
    test(
      'validateForCountry should return valid for a valid US number (default config)',
      () {
        final result = defaultPhoneValidator.validateForCountry(
          '1234567890',
          '+1',
        );
        expect(result.isValid, true);
        expect(result.errorMessage, null);
      },
    );

    test(
      'validateForCountry should return invalid for a US number with non-digits (default config)',
      () {
        final result = defaultPhoneValidator.validateForCountry(
          '123-456-7890',
          '+1',
        );
        expect(result.isValid, false);
        expect(
          result.errorMessage,
          'Phone number must be at most 10 digits',
        ); // Regex is strict for digits only
      },
    );

    // Test with default validator and default rule (for an unknown country)
    test(
      'validateForCountry should use default rule for unknown country code',
      () {
        final result = defaultPhoneValidator.validateForCountry(
          '1234567',
          '00',
        ); // XX is not in config
        expect(result.isValid, true);
        expect(result.errorMessage, null);
      },
    );

    test(
      'validateForCountry should return invalid for short number with default rule',
      () {
        final result = defaultPhoneValidator.validateForCountry('123', '00');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Phone number must be at least 7 digits');
      },
    );

    test(
      'validateForCountry should return invalid for non-digit with default rule',
      () {
        final result = defaultPhoneValidator.validateForCountry('123ABC', '00');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Phone number must be at least 7 digits');
      },
    );

    // Test empty phone number
    test(
      'validateForCountry should return "Phone number cannot be empty" for empty string',
      () {
        final result = defaultPhoneValidator.validateForCountry('', '+91');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Phone number cannot be empty');
      },
    );

    test(
      'validateForCountry should return "Phone number cannot be empty" for empty string using default rule',
      () {
        final result = defaultPhoneValidator.validateForCountry('', '00');
        expect(result.isValid, false);
        expect(result.errorMessage, 'Phone number cannot be empty');
      },
    );

    // Test with custom config and ES rules
    test(
      'validateForCountry should return valid for a valid Spanish number (custom config)',
      () {
        final phoneValidator = PhoneValidator(config: customConfig);
        final result = phoneValidator.validateForCountry('612345678', 'ES');
        expect(result.isValid, true);
        expect(result.errorMessage, null);
      },
    );

    // Test with custom config and JP rules
    test(
      'validateForCountry should return valid for a valid Japanese mobile number (custom config)',
      () {
        final phoneValidator = PhoneValidator(config: customConfig);
        final result = phoneValidator.validateForCountry('09012345678', 'JP');
        expect(result.isValid, true);
        expect(result.errorMessage, null);
      },
    );

    // Test when no rule exists for a country and no default rule is provided
    test(
      'validateForCountry should return valid if no rule and no default rule exists',
      () {
        final noRuleConfig = PhoneValidationConfig(
          defaultCountryCode: "",
          countryValidationRules: {},
        );
        final phoneValidator = PhoneValidator(config: noRuleConfig);
        final result = phoneValidator.validateForCountry('12345', 'ZZ');
        expect(result.isValid, true); // No rule, so implicitly valid
      },
    );

    // --- Test cases for toE164Format method ---

    test(
      'toE164Format should correctly convert to E.164 format with plus sign in country code',
      () {
        expect(
          defaultPhoneValidator.toE164Format('9876543210', '+91'),
          '+919876543210',
        );
      },
    );

    test(
      'toE164Format should correctly convert to E.164 format without plus sign in country code',
      () {
        expect(
          defaultPhoneValidator.toE164Format('9876543210', '91'),
          '+919876543210',
        );
      },
    );

    test('toE164Format should remove non-digits from phone number', () {
      expect(
        defaultPhoneValidator.toE164Format('(123) 456-7890', '+1'),
        '+11234567890',
      );
      expect(
        defaultPhoneValidator.toE164Format('123-456-7890 ext.123', '1'),
        '+11234567890123',
      ); // Removes ext.
    });

    test('toE164Format should handle country code with non-digits', () {
      expect(
        defaultPhoneValidator.toE164Format('123456789', 'US+1'),
        '+1123456789',
      ); // US+1 becomes 1
    });

    test('toE164Format should handle empty phone number', () {
      expect(defaultPhoneValidator.toE164Format('', '+91'), '+91');
    });

    test('toE164Format should handle empty country code', () {
      expect(
        defaultPhoneValidator.toE164Format('12345', ''),
        '+12345',
      ); // Becomes just the phone number if country code is blank
    });
  });
}
