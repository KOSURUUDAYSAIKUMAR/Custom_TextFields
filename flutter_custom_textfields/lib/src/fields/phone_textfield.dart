import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/country_code.dart';
import '../validator/phone_validator.dart';

enum PhoneFieldStyle { simple, dropdown, integrated, withIcons }

class FlexiblePhoneField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final InputDecoration? decoration;
  final List<CountryCode>? availableCountries;
  final int? maxLength;
  final PhoneFieldStyle style;
  final VoidCallback? onSubmitted;
  final void Function(String)? onPhoneNumberChanged;
  final String countryCode;
  final Widget? leadingIcon;
  final String hintText;
  final String hintext;
  final String? label;
  final bool isShowError;
  final String? regexPattern;
  final String? invalidPatternMessage;
  final TextStyle? textStyle;
  final PhoneValidationConfig? validationConfig;

  const FlexiblePhoneField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.style = PhoneFieldStyle.simple,
    this.hintText = 'Enter mobile number',
    this.label,
    this.countryCode = '+91',
    this.isShowError = true,
    this.regexPattern,
    this.invalidPatternMessage,
    this.maxLength = 10,
    this.decoration,
    this.leadingIcon,
    this.onPhoneNumberChanged,
    this.availableCountries,
    this.onSubmitted,
    this.textStyle,
    this.validationConfig,
    this.hintext = 'Enter mobile number',
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

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = widget.countryCode;
    _validationConfig =
        widget.validationConfig ?? PhoneValidationConfig.defaultConfig();
    _phoneValidator = PhoneValidator(config: _validationConfig);
    widget.focusNode.addListener(_handleFocusChange);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _updateBorderColor();
        if (widget.focusNode.hasFocus) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    }
  }

  void _handleSubmit() {
    widget.onSubmitted?.call();
  }

  void _updateBorderColor() {
    if (widget.focusNode.hasFocus) {
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
            child: _buildTextFormField(hintText: widget.hintText),
          ),
        ),
      ],
    );
  }

  /// Style 3: Integrated country code inside main field
  Widget _buildIntegratedStyle() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: _buildTextFormField(hintText: widget.hintText),
    );
  }

  /// Style 4: With icons and enhanced visuals
  Widget _buildWithIconsStyle() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: _buildTextFormField(
        hintText: widget.hintText,
        prefixIcon: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.smartphone_rounded,
            color:
                widget.focusNode.hasFocus
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
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.phone,
      maxLength: widget.maxLength,
      style: widget.textStyle,
      onFieldSubmitted: (_) => _handleSubmit(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {
        if (widget.onPhoneNumberChanged != null && value.isNotEmpty) {
          final formattedNumber = _phoneValidator.toE164Format(
            value,
            _selectedCountryCode,
          );
          widget.onPhoneNumberChanged!(formattedNumber);
        }
      },
      validator: (value) => _validatePhone(value),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration:
          widget.decoration ??
          InputDecoration(
            hintText: hintText ?? widget.hintText,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            prefixIcon: prefixIcon,
            suffixIcon:
                widget.controller.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        widget.controller.clear();
                        if (widget.onPhoneNumberChanged != null) {
                          widget.onPhoneNumberChanged!('');
                        }
                      },
                      color: Colors.grey[600],
                      splashRadius: 20,
                    )
                    : null,
          ),
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
