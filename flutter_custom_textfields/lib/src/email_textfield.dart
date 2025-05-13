import 'package:flutter/material.dart';
import 'package:flutter_custom_textfields/src/validators.dart';
import 'package:flutter_custom_textfields/src/custom_text_field.dart';

class EmailTextfield extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? customValidator;
  final bool enabled;
  final FocusNode? focusNode;
  final Color? iconColor;
  final InputDecoration? inputDecoration;

  const EmailTextfield({
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
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      leadingIcon: Icon(Icons.email_outlined, color: iconColor ?? Colors.grey),
      validator: customValidator ?? Validators.validateEmail,
      onChanged: onChanged,
      enabled: enabled,
      focusNode: focusNode,
      inputDecoration: inputDecoration,
    );
  }
}
