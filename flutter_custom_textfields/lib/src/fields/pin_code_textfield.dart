import 'package:flutter/material.dart';
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';
import 'package:flutter/services.dart';
import '../utils/custom_input_decoration.dart';

class PinCodeTextfield extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? trailingIcon;
  final Widget? leadingIcon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool enabled;
  final String? initialValue;
  final int? maxLength;
  final bool readOnly;
  final void Function()? onTap;
  final Color? cursorColor;
  final BoxDecoration? decoration;
  final InputDecoration? inputDecoration;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? contentPadding;
  final TextCapitalization textCapitalization;
  final AutovalidateMode? autovalidateMode;
  final TextInputAction? textInputAction;
  final int? Function(String?)? onFieldSubmitted;
  final int? maxLines;
  final bool preventConsecutiveSpaces;
  final bool preventLeadingTrailingSpaces;
  final RegExp? inputFormatterPattern;
  final bool useInputFormatter;

  const PinCodeTextfield({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.onChanged,

    this.enabled = true,
    this.focusNode,

    this.inputDecoration,
    this.trailingIcon,
    this.leadingIcon,
    this.textCapitalization = TextCapitalization.none,

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

    this.onFieldSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.initialValue,
    this.decoration,
    this.maxLines,
  });

  @override
  State<PinCodeTextfield> createState() => _PinCodeTextfieldState();
}

class _PinCodeTextfieldState extends State<PinCodeTextfield> {
  @override
  Widget build(BuildContext context) {
    final String? effectiveLabel =
        widget.label?.isNotEmpty == true ? widget.label : null;
    final String? effectiveHint =
        widget.hint?.isNotEmpty == true ? widget.hint : null;
    final effectiveDecoration =
        widget.inputDecoration ??
        CustomInputDecorations.build(
          context: context,
          label: effectiveLabel,
          hint: effectiveHint,
          prefixIcon: widget.leadingIcon,
          suffixIcon: widget.trailingIcon,
          contentPadding: widget.contentPadding,
        );

    List<TextInputFormatter> effectiveInputFormatters = [];
    if (widget.inputFormatters != null) {
      effectiveInputFormatters.addAll(widget.inputFormatters!);
    }
    if (widget.useInputFormatter &&
        widget.keyboardType == TextInputType.number) {
      effectiveInputFormatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (widget.maxLength != null) {
      effectiveInputFormatters.add(
        LengthLimitingTextInputFormatter(widget.maxLength),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          maxLines: widget.maxLines ?? 1,
          decoration: widget.decoration,
          initialValue: widget.initialValue,
          obscureText: widget.obscureText,
          label: effectiveLabel,
          hint: effectiveHint,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          leadingIcon: widget.leadingIcon,
          trailingIcon: widget.trailingIcon,
          validator: widget.validator,

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
          preventConsecutiveSpaces: widget.preventConsecutiveSpaces,
          preventLeadingTrailingSpaces: widget.preventLeadingTrailingSpaces,
        ),
      ],
    );
  }
}
