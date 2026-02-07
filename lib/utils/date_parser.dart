import 'package:intl/intl.dart';

class DateParser {
  static DateTime? parse(String value) {
    if (value.trim().isEmpty) return null;

    final formats = [
      DateFormat('yyyy-MM-dd'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('MM/dd/yyyy'),
      DateFormat('dd-MM-yyyy'),
      DateFormat('yyyy/MM/dd'),
      DateFormat('dd-MMM-yyyy'),
      DateFormat('dd MMM yyyy'),
      DateFormat('MMM dd, yyyy'),
      DateFormat('d/M/yyyy'),
      DateFormat('d-M-yyyy'),
    ];

    for (final format in formats) {
      try {
        return format.parseStrict(value.trim());
      } catch (_) {}
    }

    return null;
  }
}
