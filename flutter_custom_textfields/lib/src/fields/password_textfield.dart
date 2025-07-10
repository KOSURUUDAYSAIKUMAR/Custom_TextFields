import 'package:flutter/material.dart';
import 'package:flutter_custom_textfields/custom_text_field.dart';
import 'package:flutter_custom_textfields/src/validator/passowrd_validator.dart';

class PasswordTextfield extends StatefulWidget {
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
  final String? customRegexPattern;
  final String? invalidPasswordMessage;
  final String? requiredPasswordMessage;
  final TextEditingController? compareWithController;
  final String? passwordMismatchMessage;
  final AutovalidateMode? autovalidateMode;

  const PasswordTextfield({
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
    this.customRegexPattern,
    this.invalidPasswordMessage,
    this.requiredPasswordMessage,
    this.compareWithController,
    this.passwordMismatchMessage,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
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
    // Determine which validator to use: custom or the built-in PasswordValidator.
    if (widget.customValidator != null) {
      // If a custom validator is provided, use it directly.
      validator = widget.customValidator!;
    } else {
      // Otherwise, use the internal password validation logic from PasswordValidator.
      validator = (value) {
        final String? standardValidationError =
            PasswordValidator.validatePassword(
              value,
              customRegexPattern: widget.customRegexPattern,
              invalidPasswordMessage: widget.invalidPasswordMessage,
              requiredPasswordMessage: widget.requiredPasswordMessage,
            );
        if (standardValidationError != null) {
          return standardValidationError;
        }
        if (widget.compareWithController != null) {
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

    return CustomTextField(
      label: effectiveLabel,
      hint: effectiveHint,
      controller: widget.controller,
      keyboardType: TextInputType.visiblePassword,
      leadingIcon: widget.leadingIcon,
      obscureText: _obscureText,
      trailingIcon:
          widget.trailingIcon ??
          GestureDetector(
            onTap: _toggleObscureText,
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: widget.iconColor ?? Colors.grey,
            ),
          ),
      validator: validator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      inputDecoration: widget.inputDecoration,
      textCapitalization: TextCapitalization.none,
      autovalidateMode: widget.autovalidateMode,
    );
  }
}
