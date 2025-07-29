class CountryCode {
  final String name;
  final String code;
  final String? flag;
  CountryCode({required this.name, required this.code, this.flag});
}

class CountryValidationRule {
  final String regex;
  final String? errorMessage;
  final int? minLength;
  final int? maxLength;
  const CountryValidationRule({
    required this.regex,
    this.errorMessage,
    this.minLength,
    this.maxLength,
  });
  @override
  String toString() {
    return 'CountryValidationRule('
        'regex: $regex, '
        'errorMessage: $errorMessage, '
        'minLength: $minLength, '
        'maxLength: $maxLength)';
  }
}

class PhoneValidationConfig {
  final String defaultCountryCode;
  final Map<String, CountryValidationRule> countryValidationRules;
  final CountryValidationRule? defaultValidationRule;
  const PhoneValidationConfig({
    required this.defaultCountryCode,
    required this.countryValidationRules,
    this.defaultValidationRule,
  });

  factory PhoneValidationConfig.defaultConfig() {
    return PhoneValidationConfig(
      defaultCountryCode: '+91',
      countryValidationRules: {
        '+91': const CountryValidationRule(
          regex: r'^[6-9]\d{9}$',
          errorMessage: 'Mobile number must start with 6, 7, 8, or 9 digits',
          minLength: 10,
          maxLength: 10,
        ),
        '+1': const CountryValidationRule(
          regex: r'^\d{10}$',
          errorMessage: 'US/Canada numbers must be 10 digits',
          minLength: 10,
          maxLength: 10,
        ),
        '+65': const CountryValidationRule(
          regex: r'^\d{8}$',
          errorMessage: 'Singapore numbers must be 8 digits',
          minLength: 8,
          maxLength: 8,
        ),
        '+44': const CountryValidationRule(
          regex: r'^\d{10,11}$',
          errorMessage: 'UK numbers must be 10-11 digits',
          minLength: 10,
          maxLength: 11,
        ),
      },
      defaultValidationRule: const CountryValidationRule(
        regex: r'^\d{7,15}$',
        errorMessage: 'Phone number must be between 7 and 15 digits',
        minLength: 7,
        maxLength: 15,
      ),
    );
  }
}
