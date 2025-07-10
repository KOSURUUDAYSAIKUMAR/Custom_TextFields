import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../custom_text_field.dart';
import '../validator/fullname_validator.dart';

class FullNameTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? customValidator;
  final bool enabled;
  final FocusNode? focusNode;
  final Color? iconColor;
  final InputDecoration? inputDecoration;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final String? customRegexPattern;
  final String? invalidNameMessage;
  final String? requiredNameMessage;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;

  const FullNameTextField({
    super.key,
    this.label = 'Full Name',
    this.hint = 'Enter your full name',
    this.controller,
    this.onChanged,
    this.customValidator,
    this.enabled = true,
    this.focusNode,
    this.iconColor,
    this.inputDecoration,
    this.leadingIcon,
    this.trailingIcon,
    this.customRegexPattern,
    this.invalidNameMessage,
    this.requiredNameMessage,
    this.maxLength,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<FullNameTextField> createState() => _FullNameTextFieldState();
}

class _FullNameTextFieldState extends State<FullNameTextField> {
  @override
  Widget build(BuildContext context) {
    if (widget.customRegexPattern != null) {
      FullnameValidator.setCustomPattern(widget.customRegexPattern!);
    }
    String? Function(String?) validator;
    if (widget.customValidator != null) {
      validator = widget.customValidator!;
    } else if (widget.invalidNameMessage != null ||
        widget.requiredNameMessage != null) {
      validator =
          (value) => FullnameValidator.validateFullNameWithCustomMessage(
            value,
            errorMessage:
                widget.invalidNameMessage ?? 'Please enter a valid name',
            requiredMessage:
                widget.requiredNameMessage ?? 'Full name is required',
          );
    } else {
      validator = FullnameValidator.validateFullName;
    }
    final String? effectiveLabel =
        widget.label?.isNotEmpty == true ? widget.label : null;
    final String? effectiveHint =
        widget.hint?.isNotEmpty == true ? widget.hint : null;

    return CustomTextField(
      label: effectiveLabel,
      hint: effectiveHint,
      controller: widget.controller,
      keyboardType: TextInputType.name,
      leadingIcon: widget.leadingIcon,
      trailingIcon: widget.trailingIcon,
      validator: validator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      inputDecoration: widget.inputDecoration,
      textCapitalization: TextCapitalization.words,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      autovalidateMode: widget.autovalidateMode,
    );
  }
}
