import 'package:flutter/material.dart';
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';
import 'package:flutter/services.dart';

class PinCodeTextfield extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? customValidator;
  final bool enabled;
  final FocusNode? focusNode;
  final Color? iconColor;
  final InputDecoration? inputDecoration;
  final Widget? trailingIcon;
  final Widget? leadingIcon;
  final TextCapitalization textCapitalization;
  final RegExp? validationPattern;
  final TextInputAction? textInputAction;
  final bool preventConsecutiveSpaces;
  final bool preventLeadingTrailingSpaces;
  final RegExp? inputFormatterPattern;
  final bool useInputFormatter;
  final int? maxLength;
  final bool readOnly;
  final Color? cursorColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputType keyboardType;
  final AutovalidateMode? autovalidateMode;
  final String? invalidMessage;
  final String? requiredMessage;
  final void Function(Map<String, dynamic>)? onValidationComplete;
  final bool validateOnComplete;

  const PinCodeTextfield({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.customValidator,
    this.enabled = true,
    this.focusNode,
    this.iconColor,
    this.inputDecoration,
    this.trailingIcon,
    this.leadingIcon,
    this.textCapitalization = TextCapitalization.none,
    this.validationPattern,
    this.textInputAction = TextInputAction.done,
    this.preventConsecutiveSpaces = true,
    this.preventLeadingTrailingSpaces = true,
    this.inputFormatterPattern,
    this.useInputFormatter = true,
    this.maxLength = 6,
    this.readOnly = false,
    this.cursorColor,
    this.textStyle,
    this.contentPadding,
    this.keyboardType = TextInputType.number,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.invalidMessage = 'Invalid PIN code',
    this.requiredMessage = 'PIN code is required',
    this.onValidationComplete,
    this.validateOnComplete = true,
  });

  @override
  State<PinCodeTextfield> createState() => _PinCodeTextfieldState();
}

class _PinCodeTextfieldState extends State<PinCodeTextfield> {
  bool isLoading = false;
  Map<String, dynamic>? apiResponse;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.controller?.text.length == widget.maxLength &&
        widget.validateOnComplete) {
      _validatePinCode();
    }
  }

  Future<void> _validatePinCode() async {
    if (widget.controller == null || widget.controller!.text.isEmpty) {
      setState(() {
        _validationError = widget.requiredMessage;
      });
      widget.onValidationComplete?.call({
        'Status': 'Error',
        'Message': widget.requiredMessage,
        'PostOffice': null,
      });
      return;
    }

    if (widget.controller!.text.length != 6) {
      setState(() {
        _validationError = 'PIN code must be 6 digits';
      });
      widget.onValidationComplete?.call({
        'Status': 'Error',
        'Message': 'PIN code must be 6 digits',
        'PostOffice': null,
      });
      return;
    }

    setState(() {
      isLoading = true;
      apiResponse = null;
      _validationError = null;
    });

    try {
      final pinCode = widget.controller!.text.trim();
      final model = PinCodeModel(
        pinCode,
        invalidMessage: widget.invalidMessage,
        requiredMessage: widget.requiredMessage,
      );
      final response = await model.validatePinCode();

      setState(() {
        isLoading = false;
        apiResponse = response;
        if (response['Status'] != 'Success') {
          // _validationError = response['Message'] ?? widget.invalidMessage;
          _validationError = widget.invalidMessage;
        }
      });

      widget.onValidationComplete?.call(response);
    } catch (e) {
      final errorResponse = {
        'Status': 'Error',
        'Message': 'Validation failed: ${e.toString()}',
        'PostOffice': null,
      };
      setState(() {
        isLoading = false;
        _validationError = errorResponse['Message'];
      });
      widget.onValidationComplete?.call(errorResponse);
    }
  }

  String? _combinedValidator(String? value) {
    // First run custom validator if provided
    if (widget.customValidator != null) {
      final customError = widget.customValidator!(value);
      if (customError != null) return customError;
    }
    // Basic validation
    if (value == null || value.isEmpty) {
      return widget.requiredMessage;
    }
    if (value.length != 6) {
      return 'PIN code must be 6 digits';
    }
    // Then check our API validation error if exists
    if (_validationError != null) {
      return _validationError;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String? effectiveLabel =
        widget.label?.isNotEmpty == true ? widget.label : null;
    final String? effectiveHint =
        widget.hint?.isNotEmpty == true ? widget.hint : null;
    final effectiveDecoration =
        widget.inputDecoration ??
        InputDecoration(
          labelText: effectiveLabel,
          hintText: effectiveHint,
          prefixIcon: widget.leadingIcon,
          suffixIcon: widget.trailingIcon,
          contentPadding:
              widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: effectiveLabel,
          hint: effectiveHint,
          controller: widget.controller,
          keyboardType: TextInputType.number,
          textInputAction: widget.textInputAction,
          leadingIcon: widget.leadingIcon,
          trailingIcon: widget.trailingIcon,
          validator: _combinedValidator,
          onChanged: (value) {
            if (_validationError != null && value.isNotEmpty) {
              setState(() {
                _validationError = null;
              });
            }
            widget.onChanged?.call(value);
          },
          onFieldSubmitted: (_) => _validatePinCode(),
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          inputDecoration: effectiveDecoration,
          textCapitalization: widget.textCapitalization,
          maxLength: widget.maxLength,
          readOnly: widget.readOnly,
          cursorColor: widget.cursorColor ?? Theme.of(context).primaryColor,
          textStyle: widget.textStyle,
          autovalidateMode: widget.autovalidateMode,
          inputFormatters: [
            if (widget.useInputFormatter)
              FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(widget.maxLength),
          ],
        ),
        // if (_apiResponse != null && _apiResponse!['Status'] == 'Success')
        //   Padding(
        //     padding: const EdgeInsets.only(top: 8.0),
        //     child: Text(
        //       _apiResponse!['PostOffice']?[0]['Name'] ?? 'Valid PIN code',
        //       style: Theme.of(
        //         context,
        //       ).textTheme.bodySmall?.copyWith(color: Colors.green),
        //     ),
        //   ),
      ],
    );
  }
}
