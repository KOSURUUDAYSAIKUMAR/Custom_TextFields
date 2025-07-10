import 'package:flutter/material.dart';
import '../../custom_text_field.dart';
import '../validator/email_validator.dart';

class EmailTextField extends StatefulWidget {
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
  final String? customRegexPattern;
  final String? invalidEmailMessage;
  final String? requiredEmailMessage;
  final AutovalidateMode? autovalidateMode;

  const EmailTextField({
    super.key,
    this.label = 'Email',
    this.hint = 'Enter your email',
    this.controller,
    this.onChanged,
    this.customValidator,
    this.enabled = true,
    this.focusNode,
    this.iconColor,
    this.inputDecoration,
    this.trailingIcon,
    this.customRegexPattern,
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
    if (widget.customRegexPattern != null) {
      EmailValidator.setCustomPattern(widget.customRegexPattern!);
    }
    String? Function(String?) validator;
    if (widget.customValidator != null) {
      validator = widget.customValidator!;
    } else if (widget.invalidEmailMessage != null ||
        widget.requiredEmailMessage != null) {
      validator =
          (value) => EmailValidator.validateEmailWithCustomMessage(
            value,
            errorMessage:
                widget.invalidEmailMessage ?? 'Please enter a valid email',
            requiredMessage: widget.requiredEmailMessage ?? 'Email is required',
          );
    } else {
      validator = EmailValidator.validateEmail;
    }
    final String? effectiveLabel =
        widget.label?.isNotEmpty == true ? widget.label : null;
    final String? effectiveHint =
        widget.hint?.isNotEmpty == true ? widget.hint : null;
    return CustomTextField(
      label: effectiveLabel,
      hint: effectiveHint,
      controller: widget.controller,
      keyboardType: TextInputType.emailAddress,
      leadingIcon: Icon(
        Icons.email_outlined,
        color: widget.iconColor ?? Colors.grey,
      ),
      trailingIcon: widget.trailingIcon,
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
