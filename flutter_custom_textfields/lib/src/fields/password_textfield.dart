import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_textfields/custom_text_field.dart';
import 'package:flutter_custom_textfields/src/validator/passowrd_validator.dart';
import '../utils/custom_input_decoration.dart';

class PasswordTextfield extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final bool enabled;
  final FocusNode? focusNode;
  final String? initialValue;
  final int?
  maxLength; // This is a TextField property for max characters, distinct from validation max length
  final bool readOnly;
  final void Function()? onTap;
  final Color? cursorColor;
  final BoxDecoration? decoration;
  final InputDecoration? inputDecoration;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry contentPadding;
  final TextCapitalization textCapitalization;
  final AutovalidateMode? autovalidateMode;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final int? maxLines;
  final Color? iconColor;
  final String? invalidPasswordMessage;
  final String? requiredPasswordMessage;
  final bool preventConsecutiveSpaces;
  final bool preventLeadingTrailingSpaces;
  final RegExp? inputFormatterPattern;
  final RegExp? validationPattern;
  final bool useInputFormatter;

  final TextEditingController? compareWithController;
  final String? passwordMismatchMessage;
  final int minPasswordLength;
  final int maxPasswordLength;

  const PasswordTextfield({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.visiblePassword,
    this.leadingIcon,
    this.trailingIcon,
    this.validator,
    this.inputFormatters,
    this.onChanged,
    this.enabled = true,
    this.focusNode,
    this.initialValue,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
    this.cursorColor,
    this.decoration,
    this.textStyle,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onFieldSubmitted,
    this.maxLines,
    this.preventConsecutiveSpaces = true,
    this.preventLeadingTrailingSpaces = true,
    this.inputFormatterPattern,
    this.validationPattern,
    this.useInputFormatter = true,
    this.iconColor,
    this.inputDecoration,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.invalidPasswordMessage,
    this.requiredPasswordMessage,
    this.compareWithController,
    this.passwordMismatchMessage,
    this.minPasswordLength = 6,
    this.maxPasswordLength = 10,
  });

  @override
  State<PasswordTextfield> createState() => _PasswodTextfieldState();
}

class _PasswodTextfieldState extends State<PasswordTextfield> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? Function(String?) validator;
    if (widget.validator != null) {
      validator = widget.validator!;
    } else {
      validator = (value) {
        if (widget.validationPattern != null) {
          PasswordValidator.setCustomPattern(widget.validationPattern!);
        } else {
          PasswordValidator.resetToDefaultPattern(
            minPasswordLength: widget.minPasswordLength,
            maxPasswordLength: widget.maxPasswordLength,
          );
        }
        final String? standardValidationError =
            PasswordValidator.validatePassword(
              value,
              invalidPasswordMessage: widget.invalidPasswordMessage,
              requiredPasswordMessage: widget.requiredPasswordMessage,
              minPasswordLength: widget.minPasswordLength,
              maxPasswordLength: widget.maxPasswordLength,
            );
        if (standardValidationError != null) {
          return standardValidationError;
        }
        // Check for password mismatch only if compareWithController is provided
        if (widget.compareWithController != null &&
            widget.compareWithController!.text.isNotEmpty) {
          if (value != widget.compareWithController!.text) {
            return widget.passwordMismatchMessage ?? 'Passwords do not match.';
          }
        }
        return null;
      };
    }
    final String? effectiveLabel =
        widget.label?.isNotEmpty == true ? widget.label : null;
    final String? effectiveHint =
        widget.hint?.isNotEmpty == true ? widget.hint : null;
    final leadingIcon =
        widget.leadingIcon ??
        Icon(Icons.lock_outline, color: widget.iconColor ?? Colors.grey);
    final trailingIcon =
        widget.trailingIcon ??
        GestureDetector(
          onTap: _toggleObscureText,
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: widget.iconColor ?? Colors.grey,
          ),
        );
    final List<TextInputFormatter> effectiveInputFormatters = [
      if (widget.useInputFormatter) ...?_buildPasswordInputFormatters(),
      ...?widget.inputFormatters,
    ];
    final effectiveDecoration =
        widget.inputDecoration ??
        CustomInputDecorations.build(
          context: context,
          label: effectiveLabel,
          hint: effectiveHint,
          prefixIcon: leadingIcon,
          suffixIcon: trailingIcon,
          contentPadding: widget.contentPadding,
        );
    return CustomTextField(
      maxLines: widget.maxLines,
      decoration: widget.decoration,
      initialValue: widget.initialValue,
      obscureText: widget.obscureText,
      label: effectiveLabel,
      hint: effectiveHint,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      validator: validator,
      onChanged: (value) {
        widget.onChanged?.call(value);
      },
      onFieldSubmitted: (p0) {
        widget.onFieldSubmitted?.call(p0);
      },
      onTap: () {
        widget.onTap?.call();
      },
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      inputDecoration: effectiveDecoration,
      textCapitalization: widget.textCapitalization,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      cursorColor: widget.cursorColor ?? Theme.of(context).primaryColor,
      textStyle: widget.textStyle,
      autovalidateMode: widget.autovalidateMode,
      inputFormatters: effectiveInputFormatters,
      inputFormatterPattern: widget.inputFormatterPattern,
      preventConsecutiveSpaces: widget.preventConsecutiveSpaces,
      preventLeadingTrailingSpaces: widget.preventLeadingTrailingSpaces,
    );
  }

  List<TextInputFormatter>? _buildPasswordInputFormatters() {
    // This formatter allows common password characters:
    // Alphanumeric, common special characters.
    // It specifically disallows consecutive spaces and leading/trailing spaces,
    // which are often undesirable in passwords, even if the validator checks for them.
    return [
      // Allow most printable ASCII characters that are common in passwords
      FilteringTextInputFormatter.allow(
        widget.inputFormatterPattern ??
            RegExp(r'[a-zA-Z0-9!@#$%^&*()_+={}\[\]:;<>,.?/~\\-]'),
      ),
      // Prevent consecutive spaces if preventConsecutiveSpaces is true
      if (widget.preventConsecutiveSpaces)
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.contains('  ')) {
            return oldValue;
          }
          return newValue;
        }),
      // Prevent leading/trailing spaces if preventLeadingTrailingSpaces is true
      if (widget.preventLeadingTrailingSpaces)
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.startsWith(' ') || newValue.text.endsWith(' ')) {
            // Only prevent if the space is actively being typed at the ends
            if (newValue.text.length > oldValue.text.length) {
              if (newValue.text.length == 1 && newValue.text == ' ') {
                return TextEditingValue.empty; // Prevent starting with a space
              }
              if (newValue.text.startsWith(' ') && oldValue.text.isEmpty) {
                return TextEditingValue.empty;
              }
              if (newValue.text.endsWith(' ') && !oldValue.text.endsWith(' ')) {
                return oldValue; // Prevent adding a trailing space
              }
            }
          }
          return newValue;
        }),
    ];
  }
}
