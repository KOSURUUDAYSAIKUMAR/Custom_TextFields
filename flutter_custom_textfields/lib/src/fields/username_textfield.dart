import 'package:flutter/material.dart';

import '../../custom_text_field.dart';
import '../models/username_formatter.dart';
import '../validator/username_validator.dart';

class UsernameTextfield extends StatefulWidget {
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
  final String? patternErrorMessage;
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

  const UsernameTextfield({
    super.key,
    this.label = 'Username',
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
    this.textCapitalization = TextCapitalization.words,
    this.validationPattern,
    this.patternErrorMessage,
    this.preventConsecutiveSpaces = true,
    this.preventLeadingTrailingSpaces = true,
    this.inputFormatterPattern,
    this.useInputFormatter = true,
    this.maxLength,
    this.readOnly = false,
    this.cursorColor,
    this.textStyle,
    this.contentPadding,
    this.keyboardType = TextInputType.name,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<UsernameTextfield> createState() => _UsernameTextfieldState();
}

class _UsernameTextfieldState extends State<UsernameTextfield> {
  @override
  Widget build(BuildContext context) {
    final effectiveLeadingIcon =
        widget.leadingIcon ??
        Icon(Icons.person, color: widget.iconColor ?? Colors.grey);
    final String? effectiveLabel =
        widget.label?.isNotEmpty == true ? widget.label : null;
    final String? effectiveHint =
        widget.hint?.isNotEmpty == true ? widget.hint : null;
    final effectiveDecoration =
        widget.inputDecoration ??
        InputDecoration(
          labelText: effectiveLabel,
          hintText: effectiveHint,
          prefixIcon: effectiveLeadingIcon,
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

    return CustomTextField(
      label: effectiveLabel,
      hint: effectiveHint,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      leadingIcon: widget.leadingIcon,
      trailingIcon: widget.trailingIcon,
      validator:
          widget.customValidator ??
          UsernameValidator.createValidator(
            pattern: widget.validationPattern,
            patternErrorMessage: widget.patternErrorMessage,
            preventConsecutiveSpaces: widget.preventConsecutiveSpaces,
            preventLeadingTrailingSpaces: widget.preventLeadingTrailingSpaces,
          ),
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      inputDecoration: effectiveDecoration,
      inputFormatters:
          widget.useInputFormatter
              ? [
                UsernameInputFormatter(
                  pattern:
                      widget.inputFormatterPattern ?? widget.validationPattern,
                  preventConsecutiveSpaces: widget.preventConsecutiveSpaces,
                ),
              ]
              : null,
      textCapitalization: widget.textCapitalization,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      cursorColor: widget.cursorColor ?? Theme.of(context).primaryColor,
      textStyle: widget.textStyle,
      autovalidateMode: widget.autovalidateMode,
    );
  }
}
