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
    'dd-MM-yyyy HH:mm:ss',
    'dd/MM/yyyy HH:mm:ss',
    'MM/dd/yyyy HH:mm:ss',
    'yyyy/MM/dd HH:mm:ss',
    
    // Date-only formats
    'yyyy-MM-dd',
    'dd-MM-yyyy',
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy/MM/dd',
    'dd.MM.yyyy',
    'MM.dd.yyyy',
    
    // Month name formats
    'dd-MMM-yyyy',
    'dd MMM yyyy',
    'MMM dd, yyyy',
    'dd MMMM yyyy',
    'MMMM dd, yyyy',
    'yyyy MMM dd',
    
    // With time and AM/PM
    'yyyy-MM-dd hh:mm:ss a',
    'dd-MM-yyyy hh:mm:ss a',
    'MM/dd/yyyy hh:mm a',
    'dd MMM yyyy hh:mm a',
    
    // Unix timestamp (as string)
    'timestamp',
  ];

  /// Parses a date string from various formats automatically
  static DateTime parse(String dateString) {
    if (dateString.isEmpty) {
      throw const FormatException('Date string is empty');
    }

    // Try parsing as Unix timestamp first
    if (_isNumeric(dateString)) {
      try {
        final timestamp = int.parse(dateString);
        // Handle milliseconds vs seconds
        if (timestamp > 946684800000) { // After year 2000 in milliseconds
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else {
          return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        }
      } catch (e) {
        // Continue to other parsing methods
      }
    }

    // Try each pattern until one works
    for (String pattern in _datePatterns) {
      try {
        if (pattern == 'timestamp') continue; // Already handled above
        
        return DateFormat(pattern).parse(dateString);
      } catch (e) {
        // Continue to next pattern
      }
    }

    // Try DateTime.parse as last resort
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
    return dateStrings.map((str) => tryParse(str)).whereType<DateTime>().toList();
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
}