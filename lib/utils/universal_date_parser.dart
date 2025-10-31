import 'package:intl/intl.dart';

class UniversalDateParser {
  static final List<String> _datePatterns = [
    // Common formats with time
    'yyyy-MM-dd HH:mm:ss',
    'yyyy-MM-dd HH:mm',
    'yyyy-MM-ddTHH:mm:ss',
    'yyyy-MM-ddTHH:mm:ssZ',
    'yyyy-MM-ddTHH:mm:ss.SSSZ',
    'yyyy-MM-ddTHH:mm:ss.SSS',
    'yyyy-MM-ddTHH:mm',
    'yyyy-MM-dd HH:mm:ss.SSS',
    'dd-MM-yyyy HH:mm:ss',
    'dd/MM/yyyy HH:mm:ss',
    'MM/dd/yyyy HH:mm:ss',
    'MM-dd-yyyy HH:mm:ss',
    'yyyy/MM/dd HH:mm:ss',
    'MM.dd.yyyy HH:mm:ss',

    // Date-only formats
    'yyyy-MM-dd',
    'dd-MM-yyyy',
    'MM-dd-yyyy',
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy/MM/dd',
    'dd.MM.yyyy',
    'MM.dd.yyyy',
    'yyyy.MM.dd',
    'yyyyMMdd',
    'ddMMyyyy',
    'MMddyyyy',
    // Two-digit year variants
    'dd-MM-yy',
    'MM-dd-yy',
    'dd/MM/yy',
    'MM/dd/yy',
    'dd.MM.yy',
    'MM.dd.yy',

    // Month name formats
    'dd-MMM-yyyy',
    'dd MMM yyyy',
    'MMM dd, yyyy',
    'dd MMMM yyyy',
    'MMMM dd, yyyy',
    'yyyy MMM dd',
    'MMM d, yyyy',
    'EEE, dd MMM yyyy HH:mm:ss Z', // RFC 2822/822 style

// With time and AM/PM
    'yyyy-MM-dd hh:mm:ss a',
    'dd-MM-yyyy hh:mm:ss a',
    'MM/dd/yyyy hh:mm a',
    'dd MMM yyyy hh:mm a',
    'dd-MMM-yyyy hh:mm a',

    // Unix timestamp (as string)
    'timestamp',
  ];

  /// Parses a date string from various formats automatically
  static DateTime parse(String dateString) {
    if (dateString.isEmpty) {
      throw const FormatException('Date string is empty');
    }

    // Normalize input (trim, collapse spaces, fix timezone offset colon, etc.)
    dateString = _normalize(dateString);

    for (String pattern in _datePatterns) {
      if (pattern == 'timestamp') continue;
      try {
        // Try both en_US and system locale
        return DateFormat(pattern, 'en_US').parseStrict(dateString);
      } catch (_) {
        // Continue
      }
    }

    // If all patterns fail, try interpreting numeric strings as Unix timestamps
    if (_isNumeric(dateString)) {
      final tsStr = dateString.trim();
      // Only accept typical Unix timestamp lengths
      if (tsStr.length == 13) {
        final ms = int.parse(tsStr);
        return DateTime.fromMillisecondsSinceEpoch(ms);
      } else if (tsStr.length == 10) {
        final sec = int.parse(tsStr);
        return DateTime.fromMillisecondsSinceEpoch(sec * 1000);
      }
      // Otherwise, do not guess; continue to final fallback
    }

    // Final fallback to DateTime.parse()
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      throw FormatException('Unable to parse date: $dateString');
    }
  }

  /// Safe parsing that returns null instead of throwing exception
  static DateTime? tryParse(String dateString) {
    try {
      return parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parses multiple date strings, returning successful parses
  static List<DateTime> parseMultiple(List<String> dateStrings) {
    return dateStrings
        .map((str) => tryParse(str))
        .whereType<DateTime>()
        .toList();
  }

  /// Detects the format of a date string
  static String? detectFormat(String dateString) {
    for (String pattern in _datePatterns) {
      if (pattern == 'timestamp') continue;

      try {
        DateFormat(pattern).parse(dateString);
        return pattern;
      } catch (e) {
        // Continue to next pattern
      }
    }
    return null;
  }

  /// Checks if a string is numeric (for timestamp detection)
  static bool _isNumeric(String str) {
    if (str.isEmpty) return false;
    return double.tryParse(str) != null;
  }

  /// Normalizes common quirks in date strings before parsing
  /// - Trims whitespace and collapses multiple spaces
  /// - Converts timezone like +05:30 to +0530 (expected by DateFormat 'Z')
  /// - Removes trailing commas in month-name dates
  static String _normalize(String input) {
    String s = input.trim();
    // Collapse multiple spaces
    s = s.replaceAll(RegExp(r'\s+'), ' ');

    // Ensure a space after comma if missing (e.g., "Oct 31,2026" -> "Oct 31, 2026")
    s = s.replaceAllMapped(RegExp(r',(?=\S)'), (m) => ', ');

    // Normalize timezone offsets at end: +HH:MM or -HH:MM -> +HHMM / -HHMM
    final tzMatch = RegExp(r'([+-])(\d{2}):(\d{2})\s*$').firstMatch(s);
    if (tzMatch != null) {
      s = s.replaceFirst(RegExp(r'([+-])(\d{2}):(\d{2})\s*$'),
          '${tzMatch.group(1)}${tzMatch.group(2)}${tzMatch.group(3)}');
    }

    return s;
  }
}
