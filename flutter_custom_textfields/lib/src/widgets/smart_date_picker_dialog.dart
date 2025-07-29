import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../models/date_selection_mode.dart';
import '../controllers/date_picker_controller.dart';

/// Dialog widget for date picker
class SmartDatePickerDialog extends StatefulWidget {
  final DatePickerController controller;

  const SmartDatePickerDialog({super.key, required this.controller});

  @override
  State<SmartDatePickerDialog> createState() => _SmartDatePickerDialogState();
}

class _SmartDatePickerDialogState extends State<SmartDatePickerDialog> {
  late DateRangePickerController _pickerController;
  dynamic _tempSelection;

  @override
  void initState() {
    super.initState();
    _pickerController = DateRangePickerController();
    _tempSelection = widget.controller.selectedValue;

    // Set initial selection
    if (_tempSelection != null) {
      switch (widget.controller.config.selectionMode) {
        case DateSelectionMode.single:
          _pickerController.selectedDate = _tempSelection as DateTime?;
          break;
        case DateSelectionMode.multiple:
          _pickerController.selectedDates = List<DateTime>.from(
            _tempSelection as List<DateTime>,
          );
          break;
        case DateSelectionMode.range:
          if (_tempSelection is List<DateTime> &&
              (_tempSelection as List<DateTime>).length == 2) {
            final dates = _tempSelection as List<DateTime>;
            _pickerController.selectedRange = PickerDateRange(
              dates[0],
              dates[1],
            );
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.controller.config;
    final primaryColor = config.primaryColor ?? theme.primaryColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(
                16,
              ), // const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getHeaderText(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Date Picker
            Container(
              padding: const EdgeInsets.all(16),
              child: SfDateRangePicker(
                controller: _pickerController,
                view: DateRangePickerView.month,
                selectionMode: _getSelectionMode(),
                initialSelectedDate: _getInitialDate(),
                initialSelectedDates: _getInitialDates(),
                initialSelectedRange: _getInitialRange(),
                minDate: widget.controller.getMinimumDate(),
                maxDate: widget.controller.getMaximumDate(),
                // Use selectableDayPredicate for blackoutDates and specialDates logic
                // The `enablePastDates` check should also be incorporated here if needed.
                selectableDayPredicate: (DateTime date) {
                  // First, check the controller's base selectable predicate
                  if (!widget.controller.isDateSelectable(date)) {
                    return false;
                  }

                  // Check if the date is a blackout date
                  if (config.blackoutDates != null &&
                      config.blackoutDates!.any(
                        (blackoutDate) =>
                            DateUtils.isSameDay(blackoutDate, date),
                      )) {
                    return false;
                  }

                  // Special dates are usually just highlighted, not made unselectable.
                  // If special dates should also be selectable (which is usually the case),
                  // then no 'return false' for special dates.
                  // If you want special dates to be *exclusively* selectable or unselectable,
                  // you'd add more logic here. For now, they don't prevent selection.

                  return true; // Default to selectable if no conditions prevent it
                },

                showActionButtons: false,
                confirmText: 'OK',
                cancelText: 'Cancel',
                showNavigationArrow: true,
                toggleDaySelection: true,
                selectionShape: DateRangePickerSelectionShape.rectangle,
                selectionRadius: 8,
                monthViewSettings:
                    config.monthViewSettings ??
                    DateRangePickerMonthViewSettings(
                      // This is a class, correctly used now
                      firstDayOfWeek: 1,
                      showTrailingAndLeadingDates: true,
                      viewHeaderStyle: DateRangePickerViewHeaderStyle(
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      dayFormat: 'EEE',
                    ),
                // `yearViewSettings` is a valid parameter.
                // yearViewSettings: config.yearViewSettings,
                headerStyle:
                    config.headerStyle ??
                    DateRangePickerHeaderStyle(
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                monthCellStyle:
                    config.monthCellStyle ??
                    DateRangePickerMonthCellStyle(
                      // This is a class, correctly used now
                      textStyle:
                          config.textStyle ??
                          TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                      todayTextStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: config.primaryColor ?? theme.primaryColor,
                      ),
                      disabledDatesTextStyle: TextStyle(
                        fontSize: 14,
                        color: theme.disabledColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                      // `selectedTextStyle` is a valid parameter for DateRangePickerMonthCellStyle
                      specialDatesTextStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                      weekendTextStyle: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      blackoutDateTextStyle: TextStyle(
                        fontSize: 14,
                        color: theme.disabledColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                selectionTextStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                rangeTextStyle: TextStyle(fontSize: 14, color: Colors.white),
                selectionColor: primaryColor,
                rangeSelectionColor: primaryColor.withOpacity(0.2),
                startRangeSelectionColor: primaryColor,
                endRangeSelectionColor: primaryColor,
                todayHighlightColor: primaryColor,
                onSelectionChanged: _onSelectionChanged,
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (config.selectionMode != DateSelectionMode.single) ...[
                    TextButton(
                      onPressed: _clearSelection,
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton(
                    onPressed: _onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          config.primaryColor ?? theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _getInitialDate() {
    return widget.controller.config.selectionMode == DateSelectionMode.single
        ? _tempSelection as DateTime?
        : null;
  }

  List<DateTime>? _getInitialDates() {
    return widget.controller.config.selectionMode == DateSelectionMode.multiple
        ? _tempSelection as List<DateTime>?
        : null;
  }

  PickerDateRange? _getInitialRange() {
    return widget.controller.config.selectionMode == DateSelectionMode.range &&
            _tempSelection is List<DateTime> &&
            (_tempSelection as List<DateTime>).length == 2
        ? PickerDateRange(
          (_tempSelection as List<DateTime>)[0],
          (_tempSelection as List<DateTime>)[1],
        )
        : null;
  }

  String _getHeaderText() {
    switch (widget.controller.config.selectionMode) {
      case DateSelectionMode.single:
        return 'Select Date';
      case DateSelectionMode.multiple:
        return 'Select Dates';
      case DateSelectionMode.range:
        return 'Select Date Range';
    }
  }

  DateRangePickerSelectionMode _getSelectionMode() {
    switch (widget.controller.config.selectionMode) {
      case DateSelectionMode.single:
        return DateRangePickerSelectionMode.single;
      case DateSelectionMode.multiple:
        return DateRangePickerSelectionMode.multiple;
      case DateSelectionMode.range:
        return DateRangePickerSelectionMode.range;
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    switch (widget.controller.config.selectionMode) {
      case DateSelectionMode.single:
        _tempSelection = args.value as DateTime?;
        break;
      case DateSelectionMode.multiple:
        _tempSelection = args.value as List<DateTime>?;
        break;
      case DateSelectionMode.range:
        final range = args.value as PickerDateRange?;
        if (range != null && range.startDate != null && range.endDate != null) {
          _tempSelection = [range.startDate!, range.endDate!];
        } else {
          _tempSelection = null;
        }
        break;
    }
  }

  void _clearSelection() {
    setState(() {
      _tempSelection = null;
      _pickerController.selectedDate = null;
      _pickerController.selectedDates = null;
      _pickerController.selectedRange = null;
    });
  }

  void _onConfirm() {
    widget.controller.updateSelectedValue(_tempSelection);
    Navigator.of(context).pop();
  }
}
