import "../models/otp_configuration.dart";

class OTPValidator {
  static String? validate(String? value, {int requiredLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter OTP';
    }

    if (value.length < requiredLength) {
      return 'Please enter complete $requiredLength-digit OTP';
    }

    return null;
  }

  static bool isValidInput(String input, OTPInputType inputType) {
    switch (inputType) {
      case OTPInputType.numeric:
        return RegExp(r'^\d$').hasMatch(input);
      case OTPInputType.alphanumeric:
        return RegExp(r'^[a-zA-Z0-9]$').hasMatch(input);
      case OTPInputType.custom:
        return input.length == 1;
    }
  }

  static bool isComplete(String value, int requiredLength) {
    return value.length == requiredLength && value.trim().isNotEmpty;
  }
}
