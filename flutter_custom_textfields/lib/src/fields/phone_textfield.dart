import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';
import '../utils/custom_input_decoration.dart';

enum PhoneFieldStyle { simple, dropdown, integrated, withIcons }

class FlexiblePhoneField extends StatefulWidget {
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
  final String? invalidNumberMessage;
  final String? requiredNumberMessage;
  final bool preventConsecutiveSpaces;
  final bool preventLeadingTrailingSpaces;
  final RegExp? inputFormatterPattern;
  final RegExp? validationPattern;
  final bool useInputFormatter;

  final List<CountryCode>? availableCountries;
  final PhoneFieldStyle style;
  final String countryCode;
  final PhoneValidationConfig? validationConfig;

  const FlexiblePhoneField({
    super.key,
    this.label,
    this.hint = 'Enter mobile number',
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.phone,
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
    this.inputDecoration,
    this.textStyle,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.textInputAction,
    this.onFieldSubmitted,
    this.maxLines,
    this.iconColor,
    this.invalidNumberMessage,
    this.requiredNumberMessage,
    this.preventConsecutiveSpaces = true,
    this.preventLeadingTrailingSpaces = true,
    this.inputFormatterPattern,
    this.validationPattern,
    this.useInputFormatter = true,
    this.availableCountries,
    this.style = PhoneFieldStyle.simple,
    this.countryCode = '+91',
    this.validationConfig,
  });

  @override
  State<FlexiblePhoneField> createState() => _FlexiblePhoneFieldState();
}

class _FlexiblePhoneFieldState extends State<FlexiblePhoneField>
    with SingleTickerProviderStateMixin {
  Color _borderColor = Colors.grey[300]!;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _selectedCountryCode = '+91';
  late PhoneValidator _phoneValidator;
  late PhoneValidationConfig _validationConfig;
  String? effectiveLabel;
  String? effectiveHint;
  Widget? leadingIcon;
  @override
  void initState() {
    super.initState();
    _selectedCountryCode = widget.countryCode;
    _validationConfig =
        widget.validationConfig ?? PhoneValidationConfig.defaultConfig();
    _phoneValidator = PhoneValidator(config: _validationConfig);
    widget.focusNode!.addListener(_handleFocusChange);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    effectiveLabel = widget.label?.isNotEmpty == true ? widget.label : null;
    effectiveHint = widget.hint?.isNotEmpty == true ? widget.hint : null;
    leadingIcon = widget.leadingIcon;
  }

  @override
  void dispose() {
    widget.focusNode!.removeListener(_handleFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _updateBorderColor();
        if (widget.focusNode!.hasFocus) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    }
  }

  void _updateBorderColor() {
    if (widget.focusNode!.hasFocus) {
      _borderColor = Theme.of(context).colorScheme.primary;
    } else {
      _borderColor = Colors.grey[300]!;
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (value.isNotEmpty && !RegExp(r'^[6-9]').hasMatch(value)) {
      return 'Number must start with 6-9';
    }
    if (value.length < 10) {
      return 'Please enter 10 digits';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Invalid phone number format';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case PhoneFieldStyle.simple:
        return _buildSimpleStyle();
      case PhoneFieldStyle.dropdown:
        return _buildDropdownStyle();
      case PhoneFieldStyle.integrated:
        return _buildIntegratedStyle();
      case PhoneFieldStyle.withIcons:
        return _buildWithIconsStyle();
    }
  }

  /// Style 1: Simple fixed country code (no dropdown)
  Widget _buildSimpleStyle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFixedCountryCode(),
        const SizedBox(width: 12),
        Flexible(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildTextFormField(),
          ),
        ),
      ],
    );
  }

  /// Style 2: Dropdown country selector
  Widget _buildDropdownStyle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownCountryCode(),
        const SizedBox(width: 12),
        Flexible(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildTextFormField(hintText: effectiveHint),
          ),
        ),
      ],
    );
  }

  /// Style 3: Integrated country code inside main field
  Widget _buildIntegratedStyle() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: _buildTextFormField(hintText: effectiveHint),
    );
  }

  /// Style 4: With icons and enhanced visuals
  Widget _buildWithIconsStyle() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: _buildTextFormField(
        hintText: effectiveHint,
        prefixIcon: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.smartphone_rounded,
            color:
                widget.focusNode!.hasFocus
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
            size: 22,
          ),
        ),
      ),
    );
  }

  /// Standard text form field used in multiple styles
  Widget _buildTextFormField({String? hintText, Widget? prefixIcon}) {
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
    final boxDecoration =
        widget.decoration ??
        BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        );

    final effectiveInputFormatters = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(10),
    ];

    return CustomTextField(
      maxLines: widget.maxLines,
      decoration: boxDecoration,
      initialValue: widget.initialValue,
      obscureText: widget.obscureText,
      label: effectiveLabel,
      hint: effectiveHint,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      leadingIcon: leadingIcon,
      trailingIcon: widget.trailingIcon,
      validator: (value) {
        return _validatePhone(value);
      },
      onChanged: (value) {
        if (widget.onChanged != null && value.isNotEmpty) {
          final formattedNumber = _phoneValidator.toE164Format(
            value,
            _selectedCountryCode,
          );
          widget.onChanged!(formattedNumber);
        }
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

  /// Dropdown country code widget (Style 2)
  Widget _buildDropdownCountryCode() {
    final countries =
        widget.availableCountries ??
        [
          CountryCode(name: 'India', code: '+91', flag: '🇮🇳'),
          CountryCode(name: 'United States', code: '+1', flag: '🇺🇸'),
          CountryCode(name: 'United Kingdom', code: '+44', flag: '🇬🇧'),
        ];

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountryCode,
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          isDense: true,
          alignment: AlignmentDirectional.center,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCountryCode = newValue;
              });
            }
          },
          items:
              countries.map<DropdownMenuItem<String>>((CountryCode country) {
                return DropdownMenuItem<String>(
                  value: country.code,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (country.flag != null)
                        Text(
                          country.flag!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        country.code,
                        style:
                            widget.textStyle ??
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  /// Fixed country code widget (Style 1)
  Widget _buildFixedCountryCode() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          _selectedCountryCode,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
