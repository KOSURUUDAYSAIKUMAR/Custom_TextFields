import 'package:flutter/material.dart';

enum OTPAnimationType { none, fade, slide, scale, rotation }

enum OTPInputType { numeric, alphanumeric, custom }

class OTPFieldDecoration {
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? selectedColor;
  final Color? errorColor;
  final Color? disabledColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final BoxShadow? boxShadow;
  final Gradient? gradient;
  final Color? backgroundColor;

  const OTPFieldDecoration({
    this.activeColor,
    this.inactiveColor,
    this.selectedColor,
    this.errorColor,
    this.disabledColor,
    this.borderWidth = 1.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.boxShadow,
    this.gradient,
    this.backgroundColor,
  });
}

class OTPFieldStyle {
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final TextStyle? placeholderStyle;
  final TextAlign textAlign;
  final String placeholderText;
  final bool showCursor;
  final Color? cursorColor;
  final double cursorWidth;
  final double cursorHeight;
  final bool showPlaceholderOnlyForEmptyBox;

  const OTPFieldStyle({
    this.width = 48.0,
    this.height = 48.0,
    this.margin,
    this.padding = const EdgeInsets.all(8.0),
    this.textStyle,
    this.placeholderStyle,
    this.textAlign = TextAlign.center,
    this.placeholderText = '',
    this.showCursor = true,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.cursorHeight = 20.0,
    this.showPlaceholderOnlyForEmptyBox = true,
  }) : assert(width >= 0, 'OTPFieldStyle.width must be >= 0'),
       assert(height >= 0, 'OTPFieldStyle.height must be >= 0');
}
