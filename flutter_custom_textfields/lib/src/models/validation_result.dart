class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult.valid() : isValid = true, errorMessage = null;
  ValidationResult.invalid(this.errorMessage) : isValid = false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationResult &&
        other.isValid == isValid &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => isValid.hashCode ^ errorMessage.hashCode;

  @override
  String toString() =>
      'ValidationResult(isValid: $isValid, errorMessage: $errorMessage)';
}
