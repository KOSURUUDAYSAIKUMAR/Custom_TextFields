class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  ValidationResult({required this.isValid, this.errorMessage});
  factory ValidationResult.valid() {
    return ValidationResult(isValid: true);
  }
  factory ValidationResult.invalid(String message) {
    return ValidationResult(isValid: false, errorMessage: message);
  }
}
