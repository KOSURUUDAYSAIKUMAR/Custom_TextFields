import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../custom_text_field.dart'; // Ensure this path is correct
import '../models/username_formatter.dart'; // Ensure this path is correct
import '../utils/custom_input_decoration.dart'; // Ensure this path is correct
import '../validator/username_validator.dart'; // Ensure this path is correct

class UsernameTextfield extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText; // Usually false for username
  final TextInputType keyboardType;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final String? Function(String?)? validator; // Use this for a custom validator
  final List<TextInputFormatter>? inputFormatters; // Additional formatters
  final void Function(String)? onChanged;
  final bool enabled;
  final FocusNode? focusNode;
  final String? initialValue;
  final int? maxLength; // TextField's maxLength, also used for validation max
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

  // Specific validation messages
  final String? invalidUsernameMessage; // For general pattern mismatch
  final String? requiredUsernameMessage; // For empty field

  // Formatting & Validation Rules
  final bool preventConsecutiveSpaces;
  final bool preventLeadingTrailingSpaces;
  final RegExp? inputFormatterPattern; // For `FilteringTextInputFormatter`
  final RegExp? validationPattern; // For `UsernameValidator`'s pattern check
  final bool useInputFormatter;
  final int? minLength; // For validation min length

  const UsernameTextfield({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false, // Default to false for username
    this.keyboardType = TextInputType.text,
    this.leadingIcon,
    this.trailingIcon,
    this.validator, // Renamed from customValidator for clarity
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
    this.textCapitalization = TextCapitalization.words,
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
    this.invalidUsernameMessage, // Used if pattern mismatch
    this.requiredUsernameMessage, // Used if username is empty
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.minLength,
  });

  @override
  State<UsernameTextfield> createState() => _UsernameTextfieldState();
}

class _UsernameTextfieldState extends State<UsernameTextfield> {
  @override
  Widget build(BuildContext context) {
    final String? effectiveLabel =
        widget.label?.isNotEmpty == true ? widget.label : null;
    final String? effectiveHint =
        widget.hint?.isNotEmpty == true ? widget.hint : null;
    final leadingIcon =
        widget.leadingIcon ??
        Icon(
          Icons.person_outline, // Changed to person icon for username
          color: widget.iconColor ?? Colors.grey,
        );
    final effectiveDecoration =
        widget.inputDecoration ??
        CustomInputDecorations.build(
          context: context,
          label: effectiveLabel,
          hint: effectiveHint,
          prefixIcon: leadingIcon,
          suffixIcon: widget.trailingIcon,
          contentPadding: widget.contentPadding,
        );

    // Determine the effective validator
    final String? Function(String?) effectiveValidator =
        widget.validator ?? // Use provided validator if available
        UsernameValidator.createValidator(
          pattern: widget.validationPattern,
          patternErrorMessage:
              widget
                  .invalidUsernameMessage, // Corrected to use invalidUsernameMessage
          requiredUsernameMessage:
              widget.requiredUsernameMessage, // Pass required message
          preventConsecutiveSpaces: widget.preventConsecutiveSpaces,
          preventLeadingTrailingSpaces: widget.preventLeadingTrailingSpaces,
          minLength: widget.minLength ?? 3,
          maxLength: widget.maxLength ?? 20,
        );

    // Determine the effective input formatters
    final List<TextInputFormatter>? effectiveInputFormatters =
        widget.useInputFormatter
            ? [
              UsernameInputFormatter(
                pattern: widget.inputFormatterPattern,
                preventConsecutiveSpaces: widget.preventConsecutiveSpaces,
                preventLeadingTrailingSpaces:
                    widget.preventLeadingTrailingSpaces, // Pass this
              ),
              ...?widget.inputFormatters, // Add any user-provided formatters
            ]
            : widget
                .inputFormatters; // Only use user-provided if not using default formatter

    return CustomTextField(
      label: effectiveLabel,
      hint: effectiveHint,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      leadingIcon: leadingIcon, // Use the determined leadingIcon
      trailingIcon: widget.trailingIcon,
      validator: effectiveValidator, // Use the effective validator
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      inputDecoration: effectiveDecoration,
      inputFormatters: effectiveInputFormatters, // Use the effective formatters
      textCapitalization: widget.textCapitalization,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      cursorColor: widget.cursorColor ?? Theme.of(context).primaryColor,
      textStyle: widget.textStyle,
      autovalidateMode: widget.autovalidateMode,
      maxLines: widget.maxLines, // Pass maxLines
      obscureText: widget.obscureText, // Pass obscureText
      onFieldSubmitted: widget.onFieldSubmitted, // Pass onFieldSubmitted
      onTap: widget.onTap, // Pass onTap
      textInputAction: widget.textInputAction, // Pass textInputAction
    );
  }
}
