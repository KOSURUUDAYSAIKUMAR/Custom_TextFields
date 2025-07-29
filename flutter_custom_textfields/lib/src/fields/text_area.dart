import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_textfields/src/validator/textarea_validator.dart';
import '../../custom_text_field.dart';
import '../utils/custom_input_decoration.dart';

class TextArea extends StatefulWidget {
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
  final String? invalidTextAreaMessage;
  final String? requiredTextAreaMessage;
  final bool preventConsecutiveSpaces;
  final bool preventLeadingTrailingSpaces;
  final RegExp? inputFormatterPattern;
  final RegExp? validationPattern;
  final bool useInputFormatter;

  final String? emptyMessage;

  final String? lengthMessage;

  const TextArea({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.multiline,
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
    this.invalidTextAreaMessage,
    this.requiredTextAreaMessage,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.emptyMessage,
    this.lengthMessage,
  });

  @override
  State<TextArea> createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController =
        widget.controller ?? TextEditingController(text: widget.initialValue);

    _textController.addListener(_updateTextAndLength);
  }

  void _updateTextAndLength() {
    widget.onChanged?.call(_textController.text);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateTextAndLength);
    if (widget.controller == null) {
      _textController.dispose();
    }
    super.dispose();
  }

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

    List<TextInputFormatter> effectiveInputFormatters = [];
    if (widget.inputFormatters != null) {
      effectiveInputFormatters.addAll(widget.inputFormatters!);
    }
    // Add formatters from CustomTextField's own properties
    if (widget.useInputFormatter &&
        widget.keyboardType == TextInputType.number) {
      effectiveInputFormatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (widget.maxLength != null) {
      effectiveInputFormatters.add(
        LengthLimitingTextInputFormatter(widget.maxLength),
      );
    }

    // Add formatter to prevent emojis
    effectiveInputFormatters.add(
      FilteringTextInputFormatter.deny(
        RegExp(
          r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
        ),
      ),
    );

    String? Function(String?) validator;
    if (widget.validator != null) {
      validator = widget.validator!;
    } else {
      validator = (value) {
        return TextAreaValidator.validate(
          value,
          maxLength: widget.maxLength ?? 0,
          emptyMessage: widget.emptyMessage ?? 'This field cannot be empty.',
          lengthMessage: widget.lengthMessage ?? 'Exceeded maximum length.',
        );
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          maxLines: widget.maxLines,
          decoration: widget.decoration,
          initialValue: widget.initialValue,
          obscureText: widget.obscureText,
          label: effectiveLabel,
          hint: effectiveHint,
          controller: _textController,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          leadingIcon: widget.leadingIcon,
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
          inputFormatters: effectiveInputFormatters,
          inputDecoration: effectiveDecoration,
          textCapitalization: widget.textCapitalization,
          readOnly: widget.readOnly,
          cursorColor: widget.cursorColor ?? Theme.of(context).primaryColor,
          textStyle: widget.textStyle,
          autovalidateMode: widget.autovalidateMode,
          preventConsecutiveSpaces: widget.preventConsecutiveSpaces,
          preventLeadingTrailingSpaces: widget.preventLeadingTrailingSpaces,
          inputFormatterPattern: widget.inputFormatterPattern,
          useInputFormatter: widget.useInputFormatter,
        ),
      ],
    );
  }
}
