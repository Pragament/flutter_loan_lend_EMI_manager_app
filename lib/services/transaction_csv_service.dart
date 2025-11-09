import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:emi_manager/data/models/transaction_model.dart';

class TransactionCsvService {
  /// Pick a CSV file from device
  Future<PlatformFile?> pickCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      return result.files.first;
    }
    return null;
  }

  /// Extract headers from CSV - FIXED VERSION
  Future<List<String>> extractCsvHeaders(PlatformFile platformFile) async {
    try {
      String csvString;

      // Handle both web and mobile
      if (platformFile.bytes != null) {
        csvString = String.fromCharCodes(platformFile.bytes!);
      } else if (platformFile.path != null) {
        final file = File(platformFile.path!);
        csvString = await file.readAsString();
      } else {
        throw Exception('Unable to read file');
      }

      // Clean the CSV string - remove BOM if present
      if (csvString.startsWith('\uFEFF')) {
        csvString = csvString.substring(1);
      }

      // Trim and ensure proper line endings
      csvString = csvString.trim().replaceAll('\r\n', '\n');

      // Debug: Print first 200 characters
      print(
          'CSV Content Preview: ${csvString.substring(0, csvString.length > 200 ? 200 : csvString.length)}');

      // Convert CSV to list with proper settings
      List<List<dynamic>> csvTable = const CsvToListConverter(
        fieldDelimiter: ',',
        textDelimiter: '"',
        textEndDelimiter: '"',
        eol: '\n',
        shouldParseNumbers: false, // Keep everything as strings initially
      ).convert(csvString);

      print('Total rows parsed: ${csvTable.length}');

      if (csvTable.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // Get ONLY the first row as headers
      List<String> headers = csvTable[0]
          .map((e) => e.toString().trim())
          .where((h) => h.isNotEmpty)
          .toList();

      print('Headers extracted: $headers');

      // Validate that we have reasonable headers
      if (headers.isEmpty) {
        throw Exception('No valid headers found in CSV file');
      }

      // Optional: Check if first row looks like data instead of headers
      if (_allCellsAreNumeric(headers)) {
        throw Exception(
            'CSV file appears to be missing headers. The first row should contain column names, not data.');
      }

      return headers;
    } catch (e) {
      print("Error extracting headers: $e");
      rethrow;
    }
  }

  /// Check if all cells in a row are numeric (indicates it's data, not headers)
  bool _allCellsAreNumeric(List<String> row) {
    if (row.isEmpty) return false;

    int numericCount = 0;
    for (var cell in row) {
      if (cell.isEmpty) continue;

      // Remove common currency symbols and try to parse
      String cleaned = cell.replaceAll(RegExp(r'[₹$€£,\s]'), '');
      if (double.tryParse(cleaned) != null) {
        numericCount++;
      }
    }

    // If more than 50% are numeric, it's likely a data row
    return numericCount > row.length / 2;
  }

  /// Parse CSV with field mapping
  Future<List<Transaction>> parseTransactionsCsv(
    PlatformFile platformFile,
    Map<String, String> fieldMapping,
    String loanLendId,
  ) async {
    try {
      String csvString;

      // Handle both web and mobile
      if (platformFile.bytes != null) {
        csvString = String.fromCharCodes(platformFile.bytes!);
      } else if (platformFile.path != null) {
        final file = File(platformFile.path!);
        csvString = await file.readAsString();
      } else {
        throw Exception('Unable to read file');
      }

      // Clean the CSV string
      if (csvString.startsWith('\uFEFF')) {
        csvString = csvString.substring(1);
      }
      csvString = csvString.trim().replaceAll('\r\n', '\n');

      List<List<dynamic>> csvTable = const CsvToListConverter(
        fieldDelimiter: ',',
        textDelimiter: '"',
        textEndDelimiter: '"',
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvString);

      if (csvTable.length < 2) {
        throw Exception(
            'CSV must have at least one header row and one data row');
      }

      // First row is headers
      List<String> headers =
          csvTable[0].map((e) => e.toString().trim()).toList();
      List<Transaction> transactions = [];

      print('Starting to parse ${csvTable.length - 1} transactions...');

      // Parse data rows (starting from row 1, not 0)
      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];

        // Skip completely empty rows
        if (row.isEmpty ||
            row.every(
                (cell) => cell == null || cell.toString().trim().isEmpty)) {
          continue;
        }

        String title = '';
        String description = '';
        double? debitAmount;
        double? creditAmount;
        DateTime? date;

        // Map each cell according to the field mapping
        for (int j = 0; j < headers.length && j < row.length; j++) {
          String headerName = headers[j];
          String fieldName = fieldMapping[headerName] ?? 'Skip';
          String cellValue = (row[j] ?? '').toString().trim();

          if (fieldName == 'Skip' || fieldName.isEmpty) continue;

          switch (fieldName) {
            case 'title':
              title = cellValue;
              break;
            case 'description':
              description = cellValue;
              break;
            case 'debit':
              debitAmount = _parseAmount(cellValue);
              break;
            case 'credit':
              creditAmount = _parseAmount(cellValue);
              break;
            case 'date':
              date = _parseDate(cellValue);
              break;
          }
        }

        // Determine transaction type and amount
        String type;
        double amount;

        if (debitAmount != null && debitAmount > 0) {
          type = 'DR';
          amount = debitAmount;
        } else if (creditAmount != null && creditAmount > 0) {
          type = 'CR';
          amount = creditAmount;
        } else {
          print('Skipping row $i: No valid amount found');
          continue; // Skip rows without valid amounts
        }

        // Use default title if empty
        if (title.isEmpty) {
          title = type == 'DR' ? 'Debit Transaction' : 'Credit Transaction';
        }

        // Use current date if parsing failed
        date ??= DateTime.now();

        transactions.add(Transaction(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          title: title,
          description: description,
          amount: amount,
          type: type,
          datetime: date,
          loanLendId: loanLendId,
        ));

        print('Parsed transaction $i: $title - $amount ($type)');
      }

      print('Successfully parsed ${transactions.length} transactions');
      return transactions;
    } catch (e) {
      print("Error parsing CSV: $e");
      rethrow;
    }
  }

  /// Parse amount from string, handling currency symbols
  double? _parseAmount(String value) {
    if (value.isEmpty) return null;

    try {
      // Remove currency symbols, commas, and spaces
      String cleaned = value.replaceAll(RegExp(r'[₹$€£,\s]'), '').trim();

      if (cleaned.isEmpty) return null;

      double parsed = double.parse(cleaned);
      return parsed > 0 ? parsed : null;
    } catch (e) {
      print('Failed to parse amount: $value');
      return null;
    }
  }

  /// Parse date from string with multiple format support
  DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;

    // List of common date formats
    List<DateFormat> formats = [
      DateFormat('yyyy-MM-dd'), // 2024-01-15
      DateFormat('dd/MM/yyyy'), // 15/01/2024
      DateFormat('MM/dd/yyyy'), // 01/15/2024
      DateFormat('dd-MM-yyyy'), // 15-01-2024
      DateFormat('yyyy/MM/dd'), // 2024/01/15
      DateFormat('dd-MMM-yyyy'), // 15-Jan-2024
      DateFormat('dd MMM yyyy'), // 15 Jan 2024
      DateFormat('MMM dd, yyyy'), // Jan 15, 2024
      DateFormat('d/M/yyyy'), // 1/5/2024
      DateFormat('d-M-yyyy'), // 1-5-2024
    ];

    for (var format in formats) {
      try {
        return format.parse(value);
      } catch (e) {
        continue;
      }
    }

    print('Failed to parse date: $value');
    return null;
  }
}
