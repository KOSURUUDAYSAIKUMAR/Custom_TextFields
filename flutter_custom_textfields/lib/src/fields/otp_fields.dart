import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../validator/otp_validator.dart';
import '../models/otp_model.dart';
import '../models/otp_configuration.dart';

class AdvancedOTPField extends StatefulWidget {
  final int length;
  final Function(String) onCompleted;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final OTPInputType inputType;
  final OTPFieldStyle fieldStyle;
  final OTPFieldDecoration fieldDecoration;
  final OTPAnimationType animationType;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool obscureText;
  final String obscuringCharacter;
  final bool enabled;
  final bool autoFocus;
  final bool autoDisposeControllers;
  final String? errorText;
  final Widget? errorWidget;
  final MainAxisAlignment mainAxisAlignment;
  final bool enableActiveFill;
  final bool useNativeKeyboard;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final bool showFieldAsBox;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool enableInteractiveSelection;
  final bool enablePinAutofill;
  final String? autofillHints;

  const AdvancedOTPField({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.onSubmitted,
    this.inputType = OTPInputType.numeric,
    this.fieldStyle = const OTPFieldStyle(),
    this.fieldDecoration = const OTPFieldDecoration(),
    this.animationType = OTPAnimationType.scale,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeInOut,
    this.obscureText = false,
    this.obscuringCharacter = '●',
    this.enabled = true,
    this.autoFocus = false,
    this.autoDisposeControllers = true,
    this.errorText,
    this.errorWidget,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.enableActiveFill = false,
    this.useNativeKeyboard = true,
    this.inputFormatters,
    this.hintText,
    this.showFieldAsBox = true,
    this.readOnly = false,
    this.focusNode,
    this.textInputAction,
    this.enableInteractiveSelection = true,
    this.enablePinAutofill = true,
    this.autofillHints,
  });

  @override
  State<AdvancedOTPField> createState() => AdvancedOTPFieldState();
}

class AdvancedOTPFieldState extends State<AdvancedOTPField>
    with TickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;
  late OTPModel _otpModel;
  late TextEditingController _mainController;
  late FocusNode _mainFocusNode;
  // bool _hasBeenFocused = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _otpModel = OTPModel.initial(widget.length);
    _mainFocusNode.addListener(() {
      if (_mainFocusNode.hasFocus) {
        // setState(() {
        //   _hasBeenFocused = true;
        // });
      }
    });
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mainFocusNode.requestFocus();
      });
    }
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _mainController = TextEditingController();
    _mainFocusNode = widget.focusNode ?? FocusNode();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.length,
      (index) =>
          AnimationController(duration: widget.animationDuration, vsync: this),
    );
    _animations =
        _animationControllers.map((controller) {
          switch (widget.animationType) {
            case OTPAnimationType.fade:
              return Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: controller,
                  curve: widget.animationCurve,
                ),
              );
            case OTPAnimationType.scale:
              return Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: controller,
                  curve: widget.animationCurve,
                ),
              );
            case OTPAnimationType.slide:
              return Tween<double>(begin: -20.0, end: 0.0).animate(
                CurvedAnimation(
                  parent: controller,
                  curve: widget.animationCurve,
                ),
              );
            case OTPAnimationType.rotation:
              return Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: controller,
                  curve: widget.animationCurve,
                ),
              );
            default:
              return Tween<double>(begin: 1.0, end: 1.0).animate(controller);
          }
        }).toList();
  }

  @override
  void dispose() {
    if (widget.autoDisposeControllers) {
      for (var controller in _controllers) {
        controller.dispose();
      }
      for (var focusNode in _focusNodes) {
        focusNode.dispose();
      }
      _mainController.dispose();
      if (widget.focusNode == null) {
        _mainFocusNode.dispose();
      }
    }
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value) {
    if (value.length > widget.length) {
      value = value.substring(0, widget.length);
    }
    List<String> newDigits = List.filled(widget.length, '');
    for (int i = 0; i < value.length; i++) {
      newDigits[i] = value[i];
      _controllers[i].text = value[i];
      _animationControllers[i].forward();
    }
    for (int i = value.length; i < widget.length; i++) {
      _controllers[i].clear();
      _animationControllers[i].reverse();
    }
    int currentIndex = value.length;
    if (currentIndex >= widget.length) {
      currentIndex = widget.length - 1;
    }
    _updateOTPModel(newDigits, currentIndex);
  }

  void _updateOTPModel(List<String> newDigits, int currentIndex) {
    String newValue = newDigits.join();
    bool isComplete = OTPValidator.isComplete(newValue, widget.length);
    setState(() {
      _otpModel = _otpModel.copyWith(
        digits: newDigits,
        value: newValue,
        isComplete: isComplete,
        currentIndex: currentIndex,
      );
    });
    widget.onChanged?.call(newValue);
    if (isComplete) {
      widget.onCompleted(newValue);
    }
  }

  void clear() {
    _mainController.clear();
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].clear();
      _animationControllers[i].reverse();
    }
    setState(() {
      _otpModel = OTPModel.initial(widget.length);
      // _hasBeenFocused = false;
    });
    if (widget.autoFocus) {
      _mainFocusNode.requestFocus();
    }
  }

  void setText(String text) {
    _mainController.text = text;
    _onChanged(text);
  }

  void animateError() {
    for (var controller in _animationControllers) {
      controller.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 500), () {
        controller.stop();
        controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 48.0; // adjust as needed
    final boxCount = widget.length;
    final minBoxWidth = 40.0;
    final maxBoxWidth = 70.0;
    final boxWidth = (screenWidth - horizontalPadding) / boxCount;
    final fieldWidth = boxWidth.clamp(minBoxWidth, maxBoxWidth);
    final fieldHeight = fieldWidth * 1.2; // proportional
    final fontSize = fieldWidth * 0.5; // proportional

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Opacity(
              opacity: 0.0,
              child: SizedBox(
                width: 0.1,
                height: 0.1,
                child: TextFormField(
                  controller: _mainController,
                  focusNode: _mainFocusNode,
                  keyboardType: _getKeyboardType(),
                  inputFormatters: _getInputFormatters(),
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  enableInteractiveSelection: widget.enableInteractiveSelection,
                  autofillHints:
                      widget.enablePinAutofill && widget.autofillHints != null
                          ? [widget.autofillHints!]
                          : null,
                  onChanged: _onChanged,
                  onFieldSubmitted: widget.onSubmitted,
                ),
              ),
            ),
            // Visible PIN fields
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: widget.mainAxisAlignment,
                children: List.generate(widget.length, (index) {
                  return _buildPinField(
                    context,
                    index,
                    hasError,
                    theme,
                    fieldWidth,
                    fieldHeight,
                    fontSize,
                  );
                }),
              ),
            ),
          ],
        ),
        if (hasError && widget.errorWidget == null) ...[
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: hasError ? 1.0 : 0.0,
            duration: widget.animationDuration,
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color:
                    widget.fieldDecoration.errorColor ??
                    theme.colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
        if (widget.errorWidget != null && hasError) ...[
          const SizedBox(height: 8),
          widget.errorWidget!,
        ],
      ],
    );
  }

  Widget _buildPinField(
    BuildContext context,
    int index,
    bool hasError,
    ThemeData theme,
    double fieldWidth,
    double fieldHeight,
    double fontSize,
  ) {
    final hasValue = index < _otpModel.value.length;
    final isActive =
        _mainFocusNode.hasFocus &&
        !_otpModel.isComplete &&
        (index == _otpModel.currentIndex ||
            (_otpModel.value.isEmpty && index == 0));
    final isFocused = _mainFocusNode.hasFocus; // Track if any field is focused
    final currentValue = hasValue ? _otpModel.digits[index] : '';
    final displayValue =
        widget.obscureText && hasValue
            ? widget.obscuringCharacter
            : currentValue;
    return GestureDetector(
      onTap:
          widget.enabled
              ? () {
                _mainFocusNode.requestFocus();
                // Fix: If tapping first box and value is empty, set controller and OTP value so first box is active
                if (_otpModel.value.isEmpty && index == 0) {
                  _mainController.text = '';
                  _onChanged('');
                } else if (index < _otpModel.value.length) {
                  String newValue = _otpModel.value.substring(0, index);
                  _mainController.text = newValue;
                  _onChanged(newValue);
                }
              }
              : null,
      child: Container(
        margin: widget.fieldStyle.margin,
        child: AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return _buildAnimatedContainer(
              index: index,
              hasValue: hasValue,
              isActive: isActive,
              isFocused: isFocused,
              hasError: hasError,
              displayValue: displayValue,
              theme: theme,
              fieldWidth: fieldWidth,
              fieldHeight: fieldHeight,
              fontSize: fontSize,
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedContainer({
    required int index,
    required bool hasValue,
    required bool isActive,
    required bool isFocused,
    required bool hasError,
    required String displayValue,
    required ThemeData theme,
    required double fieldWidth,
    required double fieldHeight,
    required double fontSize,
  }) {
    final double width = widget.fieldStyle.width.clamp(0.0, double.infinity);
    final double height = widget.fieldStyle.height.clamp(0.0, double.infinity);
    Widget container = Container(
      width: width,
      height: height,
      padding: widget.fieldStyle.padding,
      decoration: _buildDecoration(
        hasValue,
        isActive,
        isFocused,
        hasError,
        theme,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasValue) ...[
            Text(
              displayValue,
              style:
                  widget.fieldStyle.textStyle ??
                  theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
              textAlign: widget.fieldStyle.textAlign,
            ),
          ] else if (!hasValue &&
              widget.fieldStyle.placeholderText.isNotEmpty &&
              !isActive) ...[
            // Show placeholder only when field is empty and not active (no cursor)
            Text(
              widget.fieldStyle.placeholderText,
              style:
                  widget.fieldStyle.placeholderStyle ??
                  theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
              textAlign: widget.fieldStyle.textAlign,
            ),
          ],
          // Show cursor when field is active and focused
          if (isActive && widget.fieldStyle.showCursor && isFocused)
            // if ((isActive ||
            //         (isFocused && _otpModel.value.isEmpty && index == 0)) &&
            //     widget.fieldStyle.showCursor &&
            //     isFocused &&
            //     !hasValue)
            Container(
              width: widget.fieldStyle.cursorWidth,
              height: widget.fieldStyle.cursorHeight,
              decoration: BoxDecoration(
                color:
                    widget.fieldStyle.cursorColor ?? theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );

    // Apply animation based on type
    switch (widget.animationType) {
      case OTPAnimationType.fade:
        return AnimatedOpacity(
          opacity: hasValue ? _animations[index].value : 0.5,
          duration: widget.animationDuration,
          child: container,
        );
      case OTPAnimationType.scale:
        return Transform.scale(
          scale: hasValue ? _animations[index].value : 1.0,
          child: container,
        );
      case OTPAnimationType.slide:
        return Transform.translate(
          offset: Offset(hasValue ? 0 : _animations[index].value, 0),
          child: container,
        );
      case OTPAnimationType.rotation:
        return Transform.rotate(
          angle: hasValue ? 0 : _animations[index].value * 0.1,
          child: container,
        );
      default:
        return container;
    }
  }

  BoxDecoration _buildDecoration(
    bool hasValue,
    bool isActive,
    bool isFocused,
    bool hasError,
    ThemeData theme,
  ) {
    Color borderColor;
    if (hasError) {
      borderColor =
          widget.fieldDecoration.errorColor ?? theme.colorScheme.error;
    } else if (isActive) {
      borderColor =
          widget.fieldDecoration.selectedColor ?? theme.colorScheme.primary;
    } else if (hasValue) {
      borderColor =
          widget.fieldDecoration.activeColor ?? theme.colorScheme.primary;
    } else if (isFocused) {
      borderColor =
          widget.fieldDecoration.activeColor ?? theme.colorScheme.primary;
    } else {
      borderColor =
          widget.fieldDecoration.inactiveColor ?? theme.colorScheme.outline;
    }

    return BoxDecoration(
      color:
          widget.enableActiveFill && hasValue
              ? (widget.fieldDecoration.backgroundColor ??
                  theme.colorScheme.primaryContainer.withOpacity(0.1))
              : (widget.fieldDecoration.backgroundColor ??
                  theme.colorScheme.surface),
      borderRadius: widget.fieldDecoration.borderRadius,
      border: Border.all(
        color: borderColor,
        width:
            isActive
                ? widget.fieldDecoration.borderWidth + 1
                : widget.fieldDecoration.borderWidth,
      ),
      boxShadow:
          widget.fieldDecoration.boxShadow != null
              ? [widget.fieldDecoration.boxShadow!]
              : isActive
              ? [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
              : null,
      gradient: widget.fieldDecoration.gradient,
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.inputType) {
      case OTPInputType.numeric:
        return TextInputType.number;
      case OTPInputType.alphanumeric:
        return TextInputType.text;
      case OTPInputType.custom:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    List<TextInputFormatter> formatters = [];
    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }
    formatters.add(LengthLimitingTextInputFormatter(widget.length));
    switch (widget.inputType) {
      case OTPInputType.numeric:
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      case OTPInputType.alphanumeric:
        formatters.add(
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        );
        break;
      case OTPInputType.custom:
        break;
    }

    return formatters;
  }
}
