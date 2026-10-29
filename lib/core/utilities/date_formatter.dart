import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy • hh:mm a');
  static final DateFormat _timeFormat = DateFormat('hh:mm:ss a');
  static final DateFormat _fileDateFormat = DateFormat('yyyyMMdd_HHmmss');

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  static String formatForFileName(DateTime dateTime) {
    return _fileDateFormat.format(dateTime);
  }
}
