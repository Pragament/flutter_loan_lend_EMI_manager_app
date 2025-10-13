import 'package:intl/intl.dart';

class DateParser {
  // List of all supported formats in your CSV
  static final List<String> supportedFormats = [
    "dd-MM-yyyy",
    "dd-MM-yy",
    "dd-MMM-yy",
    "dd-MMM-yyyy",
    "dd MMM yyyy",
    "yyyy-MM-dd",
    "MM-dd-yyyy",
  ];

  /// Tries all formats and returns a parsed DateTime or null if none match
  static DateTime? parse(String dateStr) {
    for (var format in supportedFormats) {
      try {
        return DateFormat(format).parseStrict(dateStr);
      } catch (_) {
        // ignore and try next format
      }
    }
    return null; // couldn't parse
  }

  /// Converts a DateTime to a unified format string (yyyy-MM-dd)
  static String normalize(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
  }

  /// Parses a string and returns normalized string or null if parsing fails
  static String? parseAndNormalize(String dateStr) {
    DateTime? dt = parse(dateStr);
    if (dt == null) return null;
    return normalize(dt);
  }
}
