import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

class PhoneValidator {
  final PhoneValidationConfig config;
  const PhoneValidator({required this.config});
  factory PhoneValidator.defaultValidator() {
    return PhoneValidator(config: PhoneValidationConfig.defaultConfig());
  }
  ValidationResult validateForCountry(String phoneNumber, String countryCode) {
    final rule =
        config.countryValidationRules[countryCode] ??
        config.defaultValidationRule;
    if (rule == null) {
      return ValidationResult.valid();
    }
    if (phoneNumber.isEmpty) {
      return ValidationResult.invalid('Phone number cannot be empty');
    }
    if (rule.minLength != null && phoneNumber.length < rule.minLength!) {
      return ValidationResult.invalid(
        rule.errorMessage ??
            'Phone number must be at least ${rule.minLength} digits',
      );
    }
    if (rule.maxLength != null && phoneNumber.length > rule.maxLength!) {
      return ValidationResult.invalid(
        rule.errorMessage ??
            'Phone number must be at most ${rule.maxLength} digits',
      );
    }
    if (!RegExp(rule.regex).hasMatch(phoneNumber)) {
      return ValidationResult.invalid(
        rule.errorMessage ?? 'Invalid phone number format',
      );
    }
    return ValidationResult.valid();
  }

  String toE164Format(String phoneNumber, String countryCode) {
    final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final numericCountryCode = countryCode.replaceAll(RegExp(r'[^0-9+]'), '');
    final cleanCountryCode =
        numericCountryCode.startsWith('+')
            ? numericCountryCode.substring(1)
            : numericCountryCode;

    return '+$cleanCountryCode$cleanPhoneNumber';
  }
}
