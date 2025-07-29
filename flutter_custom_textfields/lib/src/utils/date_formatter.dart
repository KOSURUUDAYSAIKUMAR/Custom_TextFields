import 'package:intl/intl.dart';
import '../models/date_selection_mode.dart';

/// Utility class for date formatting
class DateFormatter {
  /// Format a single date
  static String formatDate(DateTime date, String format) {
    try {
      final formatter = DateFormat(format);
      return formatter.format(date);
    } catch (e) {
      return DateFormat.yMd().format(date);
    }
  }

  /// Format multiple dates
  static String formatDates(List<DateTime> dates, String format) {
    if (dates.isEmpty) return '';

    if (dates.length == 1) {
      return formatDate(dates.first, format);
    }

    final sortedDates = List<DateTime>.from(dates)..sort();
    return sortedDates.map((date) => formatDate(date, format)).join(', ');
  }

  /// Format date range
  static String formatDateRange(
    DateTime startDate,
    DateTime endDate,
    String format,
  ) {
    final start = formatDate(startDate, format);
    final end = formatDate(endDate, format);
    return '$start - $end';
  }

  /// Format value based on selection mode
  static String formatValue(
    dynamic value,
    DateSelectionMode mode,
    String format,
  ) {
    if (value == null) return '';

    switch (mode) {
      case DateSelectionMode.single:
        if (value is DateTime) {
          return formatDate(value, format);
        }
        break;
      case DateSelectionMode.multiple:
        if (value is List<DateTime>) {
          return formatDates(value, format);
        }
        break;
      case DateSelectionMode.range:
        if (value is List<DateTime> && value.length == 2) {
          return formatDateRange(value[0], value[1], format);
        }
        break;
    }

    return '';
  }

  /// Parse date from string
  static DateTime? parseDate(String dateString, String format) {
    try {
      final formatter = DateFormat(format);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get relative date description
  static String getRelativeDescription(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${difference.abs()} days ago';
    }
  }
}
