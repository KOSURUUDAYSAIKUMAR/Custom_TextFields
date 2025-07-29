import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'date_selection_mode.dart';
import 'date_restriction.dart';

/// Configuration class for the Smart Date Picker
class DatePickerConfig {
  /// Selection mode for the date picker
  final DateSelectionMode selectionMode;

  /// Date restriction type
  final DateRestriction dateRestriction;

  /// Initial selected date(s)
  final dynamic initialValue;

  /// Minimum selectable date
  final DateTime? minimumDate;

  /// Maximum selectable date
  final DateTime? maximumDate;

  /// Whether to show the calendar below the text field
  final bool showCalendarBelow;

  /// Whether to hide the calendar initially
  final bool isCalendarHidden;

  /// Date format for display
  final String dateFormat;

  /// Placeholder text for the input field
  final String hintText;

  /// Label text for the input field
  final String? labelText;

  /// Icon for the input field
  final IconData? icon;

  /// Suffix icon for the input field
  final IconData? suffixIcon;

  /// Primary color for the date picker
  final Color? primaryColor;

  /// Background color for the date picker
  final Color? backgroundColor;

  /// Text style for selected dates
  final TextStyle? selectedTextStyle;

  /// Text style for normal dates
  final TextStyle? textStyle;

  /// Border decoration for the input field
  final InputBorder? border;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is required
  final bool isRequired;

  /// Validation function
  final String? Function(dynamic value)? validator;

  /// Callback when date selection changes
  final void Function(dynamic value)? onChanged;

  /// Custom blackout dates
  final List<DateTime>? blackoutDates;

  /// Custom special dates
  final List<DateTime>? specialDates;

  /// Month view settings
  final DateRangePickerMonthViewSettings? monthViewSettings;

  /// Year view settings
  final DateRangePickerYearCellStyle? yearViewSettings;

  /// Header style
  final DateRangePickerHeaderStyle? headerStyle;

  /// Month cell style
  final DateRangePickerMonthCellStyle? monthCellStyle;

  const DatePickerConfig({
    this.selectionMode = DateSelectionMode.single,
    this.dateRestriction = DateRestriction.none,
    this.initialValue,
    this.minimumDate,
    this.maximumDate,
    this.showCalendarBelow = false,
    this.isCalendarHidden = true,
    this.dateFormat = 'dd/MM/yyyy',
    this.hintText = 'Select date',
    this.labelText,
    this.icon,
    this.suffixIcon = Icons.calendar_today,
    this.primaryColor,
    this.backgroundColor,
    this.selectedTextStyle,
    this.textStyle,
    this.border,
    this.enabled = true,
    this.isRequired = false,
    this.validator,
    this.onChanged,
    this.blackoutDates,
    this.specialDates,
    this.monthViewSettings,
    this.yearViewSettings,
    this.headerStyle,
    this.monthCellStyle,
  });

  /// Create a copy of this config with updated values
  DatePickerConfig copyWith({
    DateSelectionMode? selectionMode,
    DateRestriction? dateRestriction,
    dynamic initialValue,
    DateTime? minimumDate,
    DateTime? maximumDate,
    bool? showCalendarBelow,
    bool? isCalendarHidden,
    String? dateFormat,
    String? hintText,
    String? labelText,
    IconData? icon,
    IconData? suffixIcon,
    Color? primaryColor,
    Color? backgroundColor,
    TextStyle? selectedTextStyle,
    TextStyle? textStyle,
    InputBorder? border,
    bool? enabled,
    bool? isRequired,
    String? Function(dynamic value)? validator,
    void Function(dynamic value)? onChanged,
    List<DateTime>? blackoutDates,
    List<DateTime>? specialDates,
    DateRangePickerMonthViewSettings? monthViewSettings,
    DateRangePickerYearCellStyle? yearViewSettings,
    DateRangePickerHeaderStyle? headerStyle,
    DateRangePickerMonthCellStyle? monthCellStyle,
  }) {
    return DatePickerConfig(
      selectionMode: selectionMode ?? this.selectionMode,
      dateRestriction: dateRestriction ?? this.dateRestriction,
      initialValue: initialValue ?? this.initialValue,
      minimumDate: minimumDate ?? this.minimumDate,
      maximumDate: maximumDate ?? this.maximumDate,
      showCalendarBelow: showCalendarBelow ?? this.showCalendarBelow,
      isCalendarHidden: isCalendarHidden ?? this.isCalendarHidden,
      dateFormat: dateFormat ?? this.dateFormat,
      hintText: hintText ?? this.hintText,
      labelText: labelText ?? this.labelText,
      icon: icon ?? this.icon,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      textStyle: textStyle ?? this.textStyle,
      border: border ?? this.border,
      enabled: enabled ?? this.enabled,
      isRequired: isRequired ?? this.isRequired,
      validator: validator ?? this.validator,
      onChanged: onChanged ?? this.onChanged,
      blackoutDates: blackoutDates ?? this.blackoutDates,
      specialDates: specialDates ?? this.specialDates,
      monthViewSettings: monthViewSettings ?? this.monthViewSettings,
      yearViewSettings: yearViewSettings ?? this.yearViewSettings,
      headerStyle: headerStyle ?? this.headerStyle,
      monthCellStyle: monthCellStyle ?? this.monthCellStyle,
    );
  }
}
