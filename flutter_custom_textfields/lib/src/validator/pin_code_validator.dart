// class PinCodeValidator {
//   static const String pinCodePattern = r'^[1-9]{1}[0-9]{2}\s{0,1}[0-9]{3}$';
//   static String? validate(
//     String? value,
//     String? invalidPasswordMessage,
//     String? requiredPasswordMessage,
//   ) {
//     if (value == null || value.isEmpty) {
//       return requiredPasswordMessage ?? 'PIN code is requried';
//     }
//     if (value.length == 6) {
//       return invalidPasswordMessage ?? "PIN code must be exactly 6 digits";
//     }
//     final regex = RegExp(pinCodePattern);
//     if (!regex.hasMatch(value)) {
//       return invalidPasswordMessage ?? 'Enter a valid Indian PIN code';
//     }
//     return null;
//   }
// }

// lib/src/validator/pin_code_validator.dart

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
