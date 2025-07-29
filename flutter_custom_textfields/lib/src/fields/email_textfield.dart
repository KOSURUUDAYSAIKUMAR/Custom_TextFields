import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../custom_text_field.dart';
import '../utils/custom_input_decoration.dart';
import '../validator/email_validator.dart';

class EmailTextField extends StatefulWidget {
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
  final int? maxLength;
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
  final String? invalidEmailMessage;
  final String? requiredEmailMessage;
  final bool preventConsecutiveSpaces;
  final bool preventLeadingTrailingSpaces;
  final RegExp? inputFormatterPattern;
  final RegExp? validationPattern;
  final bool useInputFormatter;

  const EmailTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.emailAddress,
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
    this.invalidEmailMessage,
    this.requiredEmailMessage,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  @override
  Widget build(BuildContext context) {
    final String? effectiveLabel =
        widget.label?.isNotEmpty == true ? widget.label : null;
    final String? effectiveHint =
        widget.hint?.isNotEmpty == true ? widget.hint : null;
    final leadingIcon =
        widget.leadingIcon ??
        Icon(Icons.email_outlined, color: widget.iconColor ?? Colors.grey);
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
    final effectiveInputFormatters = [
      if (widget.useInputFormatter) ...?_buildEmailInputFormatters(),
      ...?widget.inputFormatters,
    ];

    if (widget.validationPattern != null) {
      EmailValidator.setCustomPattern(widget.validationPattern!);
    } else {
      EmailValidator.resetToDefaultPattern();
    }
    String? Function(String?) validator;
    if (widget.validator != null) {
      validator = widget.validator!;
    } else if (widget.invalidEmailMessage != null ||
        widget.requiredEmailMessage != null) {
      validator =
          (value) => EmailValidator.validateEmailWithCustomMessage(
            value,
            errorMessage:
                widget.invalidEmailMessage ??
                'Please enter a valid email address',
            requiredMessage: widget.requiredEmailMessage ?? 'Email is required',
          );
    } else {
      validator = EmailValidator.validateEmail;
    }

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
      trailingIcon: widget.trailingIcon,
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

  List<TextInputFormatter>? _buildEmailInputFormatters() {
    return [
      // Prevent spaces in email
      FilteringTextInputFormatter.deny(RegExp(r'\s')),

      // Prevent special characters that are invalid in emails
      FilteringTextInputFormatter.deny(
        RegExp(r'[!#$%^&*()+=/\\|{}[\]:;"<>?~]'),
      ),

      // Allow only valid email characters
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._%+-]')),
    ];
  }
}
