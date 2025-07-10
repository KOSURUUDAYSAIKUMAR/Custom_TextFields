class OTPModel {
  final String value;
  final bool isComplete;
  final List<String> digits;
  final int currentIndex;
  final bool hasError;
  final String? errorMessage;

  OTPModel({
    required this.value,
    required this.isComplete,
    required this.digits,
    required this.currentIndex,
    this.hasError = false,
    this.errorMessage,
  });

  OTPModel.initial(int length)
    : value = '',
      isComplete = false,
      digits = List.filled(length, ''),
      currentIndex = 0,
      hasError = false,
      errorMessage = null;

  OTPModel copyWith({
    String? value,
    bool? isComplete,
    List<String>? digits,
    int? currentIndex,
    bool? hasError,
    String? errorMessage,
  }) {
    return OTPModel(
      value: value ?? this.value,
      isComplete: isComplete ?? this.isComplete,
      digits: digits ?? this.digits,
      currentIndex: currentIndex ?? this.currentIndex,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() => value;
}
