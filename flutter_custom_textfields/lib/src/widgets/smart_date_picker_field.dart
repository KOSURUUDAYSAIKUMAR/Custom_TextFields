import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../models/date_picker_config.dart';
import '../models/date_selection_mode.dart';
import '../controllers/date_picker_controller.dart';
import 'smart_date_picker_dialog.dart';

/// Main date picker field widget
class SmartDatePickerField extends StatefulWidget {
  final DatePickerConfig config;
  final DatePickerController? controller;

  const SmartDatePickerField({
    super.key,
    required this.config,
    this.controller,
  });

  @override
  State<SmartDatePickerField> createState() => _SmartDatePickerFieldState();
}

class _SmartDatePickerFieldState extends State<SmartDatePickerField>
    with SingleTickerProviderStateMixin {
  late DatePickerController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isControllerOwned = false;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = DatePickerController(widget.config);
      _isControllerOwned = true;
    }

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Listen to controller changes
    _controller.addListener(_onControllerChanged);

    // Show calendar initially if configured
    if (_controller.isCalendarVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_isControllerOwned) {
      _controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.isCalendarVisible && !_animationController.isCompleted) {
      _animationController.forward();
    } else if (!_controller.isCalendarVisible &&
        _animationController.isCompleted) {
      _animationController.reverse();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.config;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input Field
        _buildInputField(theme, config),

        // Calendar Below (if configured)
        if (config.showCalendarBelow) ...[
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SizeTransition(
                    sizeFactor: _fadeAnimation,
                    child:
                        _controller.isCalendarVisible
                            ? _buildInlineCalendar(theme, config)
                            : const SizedBox.shrink(),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildInputField(ThemeData theme, DatePickerConfig config) {
    return TextFormField(
      controller: TextEditingController(text: _controller.displayText),
      readOnly: true,
      enabled: config.enabled,
      decoration: InputDecoration(
        labelText: config.labelText,
        hintText: config.hintText,
        prefixIcon: config.icon != null ? Icon(config.icon) : null,
        suffixIcon: _buildSuffixIcon(theme, config),
        errorText: _controller.errorText,
        border:
            config.border ??
            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder:
            config.border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
            ),
        focusedBorder:
            config.border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: config.primaryColor ?? theme.primaryColor,
                width: 2,
              ),
            ),
        filled: true,
        fillColor: config.backgroundColor ?? theme.colorScheme.surface,
      ),
      style: config.textStyle ?? theme.textTheme.bodyMedium,
      onTap: _onFieldTap,
      validator: (value) => _controller.validate(),
    );
  }

  Widget _buildSuffixIcon(ThemeData theme, DatePickerConfig config) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Clear button (if has value)
        if (_controller.selectedValue != null && config.enabled)
          IconButton(
            icon: Icon(
              Icons.clear,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            onPressed: _controller.clearSelection,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),

        // Calendar toggle button
        IconButton(
          icon: AnimatedRotation(
            turns:
                config.showCalendarBelow && _controller.isCalendarVisible
                    ? 0.5
                    : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              config.showCalendarBelow
                  ? Icons.keyboard_arrow_down
                  : (config.suffixIcon ?? Icons.calendar_today),
              color: config.primaryColor ?? theme.primaryColor,
            ),
          ),
          onPressed: config.enabled ? _onCalendarToggle : null,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
        ),
      ],
    );
  }

  Widget _buildInlineCalendar(ThemeData theme, DatePickerConfig config) {
    final primaryColor = config.primaryColor ?? theme.primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: config.backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (config.primaryColor ?? theme.primaryColor).withOpacity(
                0.1,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: config.primaryColor ?? theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getCalendarTitle(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: config.primaryColor ?? theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (config.selectionMode != DateSelectionMode.single)
                  TextButton(
                    onPressed: _controller.clearSelection,
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: config.primaryColor ?? theme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Calendar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SfDateRangePicker(
              view: DateRangePickerView.month,
              selectionMode: _getSelectionMode(),
              initialSelectedDate: _getInitialDate(config),
              initialSelectedDates: _getInitialDates(config),
              initialSelectedRange: _getInitialRange(config),
              minDate: _controller.getMinimumDate(),
              maxDate: _controller.getMaximumDate(),
              // Use selectableDayPredicate for blackoutDates and specialDates logic
              // The `enablePastDates` check should also be incorporated here if needed.
              selectableDayPredicate: (DateTime date) {
                // First, check the controller's base selectable predicate
                if (!_controller.isDateSelectable(date)) {
                  return false;
                }

                // Check if the date is a blackout date
                if (config.blackoutDates != null &&
                    config.blackoutDates!.any(
                      (blackoutDate) => DateUtils.isSameDay(blackoutDate, date),
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
              onSelectionChanged: _onDateSelectionChanged,
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _getInitialDate(DatePickerConfig config) {
    return config.selectionMode == DateSelectionMode.single
        ? _controller.selectedValue as DateTime?
        : null;
  }

  List<DateTime>? _getInitialDates(DatePickerConfig config) {
    return config.selectionMode == DateSelectionMode.multiple
        ? _controller.selectedValue as List<DateTime>?
        : null;
  }

  PickerDateRange? _getInitialRange(DatePickerConfig config) {
    return config.selectionMode == DateSelectionMode.range &&
            _controller.selectedValue is List<DateTime> &&
            (_controller.selectedValue as List<DateTime>).length == 2
        ? PickerDateRange(
          (_controller.selectedValue as List<DateTime>)[0],
          (_controller.selectedValue as List<DateTime>)[1],
        )
        : null;
  }

  String _getCalendarTitle() {
    switch (widget.config.selectionMode) {
      case DateSelectionMode.single:
        return 'Select Date';
      case DateSelectionMode.multiple:
        return 'Select Multiple Dates';
      case DateSelectionMode.range:
        return 'Select Date Range';
    }
  }

  DateRangePickerSelectionMode _getSelectionMode() {
    switch (widget.config.selectionMode) {
      case DateSelectionMode.single:
        return DateRangePickerSelectionMode.single;
      case DateSelectionMode.multiple:
        return DateRangePickerSelectionMode.multiple;
      case DateSelectionMode.range:
        return DateRangePickerSelectionMode.range;
    }
  }

  void _onFieldTap() {
    if (!widget.config.enabled) return;

    if (widget.config.showCalendarBelow) {
      _controller.toggleCalendar();
    } else {
      _showDatePickerDialog();
    }
  }

  void _onCalendarToggle() {
    if (widget.config.showCalendarBelow) {
      _controller.toggleCalendar();
    } else {
      _showDatePickerDialog();
    }
  }

  void _showDatePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => SmartDatePickerDialog(controller: _controller),
    );
  }

  void _onDateSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    dynamic newValue;

    switch (widget.config.selectionMode) {
      case DateSelectionMode.single:
        newValue = args.value as DateTime?;
        break;
      case DateSelectionMode.multiple:
        newValue = args.value as List<DateTime>?;
        break;
      case DateSelectionMode.range:
        final range = args.value as PickerDateRange?;
        if (range != null && range.startDate != null && range.endDate != null) {
          newValue = [range.startDate!, range.endDate!];
        } else {
          newValue = null;
        }
        break;
    }

    _controller.updateSelectedValue(newValue);

    // Auto-hide calendar for single selection
    if (widget.config.selectionMode == DateSelectionMode.single &&
        widget.config.showCalendarBelow &&
        newValue != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _controller.hideCalendar();
      });
    }
  }
}
