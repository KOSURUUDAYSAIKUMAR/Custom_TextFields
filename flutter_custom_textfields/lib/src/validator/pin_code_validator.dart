class PinCodeValidator {
  static const String pinCodePattern = r'^[1-9]\d{5}$';

  static String? validate(
    String? value, {
    String? invalidPinCodeMessage,
    String? requiredPinCodeMessage,
  }) {
    if (value == null || value.isEmpty) {
      return requiredPinCodeMessage ?? 'PIN code is required.';
    }
    if (value.length != 6) {
      return invalidPinCodeMessage ?? "PIN code must be exactly 6 digits.";
    }
    final regex = RegExp(pinCodePattern);
    if (!regex.hasMatch(value)) {
      return invalidPinCodeMessage ??
          'Enter a valid Indian PIN code (e.g., first digit 1-9).';
    }
    return null;
  }
}
