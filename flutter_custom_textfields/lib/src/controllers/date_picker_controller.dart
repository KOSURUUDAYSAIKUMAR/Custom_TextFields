import 'package:flutter/material.dart';
import '../models/date_picker_config.dart';
import '../models/date_restriction.dart';
import '../utils/date_formatter.dart';

/// Controller for managing date picker state and logic
class DatePickerController extends ChangeNotifier {
  final DatePickerConfig _config;
  dynamic _selectedValue;
  bool _isCalendarVisible = false;
  String _displayText = '';
  String? _errorText;

  DatePickerController(this._config) {
    _selectedValue = _config.initialValue;
    _isCalendarVisible = !_config.isCalendarHidden;
    _updateDisplayText();
  }

  /// Current configuration
  DatePickerConfig get config => _config;

  /// Currently selected value
  dynamic get selectedValue => _selectedValue;

  /// Whether calendar is visible
  bool get isCalendarVisible => _isCalendarVisible;

  /// Display text for the input field
  String get displayText => _displayText;

  /// Error text for validation
  String? get errorText => _errorText;

  /// Update selected value
  void updateSelectedValue(dynamic value) {
    _selectedValue = value;
    _updateDisplayText();
    _validateValue();
    _config.onChanged?.call(value);
    notifyListeners();
  }

  /// Toggle calendar visibility
  void toggleCalendar() {
    _isCalendarVisible = !_isCalendarVisible;
    notifyListeners();
  }

  /// Show calendar
  void showCalendar() {
    _isCalendarVisible = true;
    notifyListeners();
  }

  /// Hide calendar
  void hideCalendar() {
    _isCalendarVisible = false;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedValue = null;
    _updateDisplayText();
    _validateValue();
    _config.onChanged?.call(null);
    notifyListeners();
  }

  /// Validate current value
  String? validate() {
    return _validateValue();
  }

  /// Check if a date is selectable based on restrictions
  bool isDateSelectable(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    // Check minimum and maximum dates
    if (_config.minimumDate != null && date.isBefore(_config.minimumDate!)) {
      return false;
    }
    if (_config.maximumDate != null && date.isAfter(_config.maximumDate!)) {
      return false;
    }

    // Check blackout dates
    if (_config.blackoutDates != null) {
      for (final blackoutDate in _config.blackoutDates!) {
        final blackout = DateTime(
          blackoutDate.year,
          blackoutDate.month,
          blackoutDate.day,
        );
        if (targetDate.isAtSameMomentAs(blackout)) {
          return false;
        }
      }
    }

    // Check date restrictions
    switch (_config.dateRestriction) {
      case DateRestriction.none:
        return true;
      case DateRestriction.pastOnly:
        return targetDate.isBefore(today);
      case DateRestriction.currentOnly:
        return targetDate.isAtSameMomentAs(today);
      case DateRestriction.futureOnly:
        return targetDate.isAfter(today);
      case DateRestriction.pastAndCurrent:
        return targetDate.isBefore(today) || targetDate.isAtSameMomentAs(today);
      case DateRestriction.currentAndFuture:
        return targetDate.isAfter(today) || targetDate.isAtSameMomentAs(today);
    }
  }

  /// Get minimum date based on restrictions
  DateTime? getMinimumDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_config.dateRestriction) {
      case DateRestriction.currentOnly:
        return today;
      case DateRestriction.futureOnly:
        return today.add(const Duration(days: 1));
      case DateRestriction.currentAndFuture:
        return today;
      default:
        return _config.minimumDate;
    }
  }

  /// Get maximum date based on restrictions
  DateTime? getMaximumDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_config.dateRestriction) {
      case DateRestriction.pastOnly:
        return today.subtract(const Duration(days: 1));
      case DateRestriction.currentOnly:
        return today;
      case DateRestriction.pastAndCurrent:
        return today;
      default:
        return _config.maximumDate;
    }
  }

  /// Update display text based on selected value
  void _updateDisplayText() {
    _displayText = DateFormatter.formatValue(
      _selectedValue,
      _config.selectionMode,
      _config.dateFormat,
    );
  }

  /// Validate the current value
  String? _validateValue() {
    _errorText = null;

    // Check if required
    if (_config.isRequired &&
        (_selectedValue == null || _displayText.isEmpty)) {
      _errorText = 'This field is required';
      return _errorText;
    }

    // Custom validation
    if (_config.validator != null) {
      _errorText = _config.validator!(_selectedValue);
      return _errorText;
    }

    return null;
  }
}
