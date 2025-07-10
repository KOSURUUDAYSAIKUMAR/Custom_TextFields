import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_textfields/src/validator/textarea_validator.dart';
import '../../custom_text_field.dart';

class TextArea extends StatefulWidget {
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
  final TextCapitalization? textCapitalization;
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
  final TextInputType? keyboardType;
  final AutovalidateMode? autovalidateMode;
  final String? initialValue;
  final TextInputAction? textInputAction;
  final String? emptyMessage;
  final String? requiredMessage;
  final String? lengthMessage;
  final List<TextInputFormatter>? inputFormatters;

  const TextArea({
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
    this.textCapitalization,
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
    this.keyboardType,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.initialValue,
    this.textInputAction,
    this.emptyMessage,
    this.requiredMessage,
    this.lengthMessage,
    this.inputFormatters,
  });

  @override
  State<TextArea> createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  late final TextEditingController _textController;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _textController =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _currentLength = _textController.text.length;
    _textController.addListener(_updateTextAndLength);
  }

  void _updateTextAndLength() {
    setState(() {
      _currentLength = _textController.text.length;
    });
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _textController,
          maxLines: null,
          keyboardType: widget.keyboardType ?? TextInputType.multiline,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          label: effectiveLabel,
          hint: effectiveHint,
          leadingIcon: widget.leadingIcon,
          trailingIcon: widget.trailingIcon,
          inputFormatters: effectiveInputFormatters,
          inputDecoration:
              widget.inputDecoration ??
              InputDecoration(
                hintText: effectiveHint,
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
          validator:
              widget.customValidator ??
              (value) {
                return TextAreaValidator.validate(
                  value,
                  maxLength: widget.maxLength ?? 0,
                  emptyMessage: widget.emptyMessage,
                  lengthMessage: widget.lengthMessage,
                );
              },
          onChanged:
              widget.onChanged ??
              (value) {
                setState(() {
                  _currentLength = value.length;
                });
                widget.onChanged?.call(value);
              },
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.none,
          readOnly: widget.readOnly,
          cursorColor: widget.cursorColor ?? Theme.of(context).primaryColor,
          textStyle: widget.textStyle,
          autovalidateMode: widget.autovalidateMode,
          preventConsecutiveSpaces: widget.preventConsecutiveSpaces,
          preventLeadingTrailingSpaces: widget.preventLeadingTrailingSpaces,
          inputFormatterPattern: widget.inputFormatterPattern,
          useInputFormatter: widget.useInputFormatter,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 4.0),
          child: Text(
            '$_currentLength / ${widget.maxLength}',
            style: TextStyle(
              fontSize: 12.0,
              color:
                  widget.maxLength != null && _currentLength > widget.maxLength!
                      ? Colors.red
                      : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
