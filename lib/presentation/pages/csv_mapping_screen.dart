import 'package:flutter/material.dart';

class CsvMappingScreen extends StatefulWidget {
  final List<String> csvHeaders;
  final Function(Map<String, String>) onMappingComplete;

  const CsvMappingScreen({
    super.key,
    required this.csvHeaders,
    required this.onMappingComplete,
  });

  @override
  State<CsvMappingScreen> createState() => _CsvMappingScreenState();
}

class _CsvMappingScreenState extends State<CsvMappingScreen> {
  final Map<String, String> fieldMapping = {};
  final List<String> appFields = [
    'title',
    'description',
    'debit',
    'credit',
    'date',
  ];

  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Initialize mapping after build to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMapping();
    });
  }

  void _initializeMapping() {
    // First pass: Find all potential mappings
    Map<String, List<String>> potentialMappings = {};
    for (var field in appFields) {
      potentialMappings[field] = [];
    }

    for (var header in widget.csvHeaders) {
      String? defaultMapping = _findDefaultMapping(header);
      if (defaultMapping != null) {
        potentialMappings[defaultMapping]!.add(header);
      }
    }

    // Second pass: Assign mappings, preferring exact matches and avoiding duplicates
    Set<String> usedFields = {};

    // Priority order for assignment (most important fields first)
    List<String> priorityOrder = [
      'date',
      'debit',
      'credit',
      'title',
      'description'
    ];

    for (var field in priorityOrder) {
      List<String> candidates = potentialMappings[field]!;
      if (candidates.isEmpty) continue;

      // Prefer exact matches
      String? bestMatch = candidates.firstWhere(
        (h) => h.toLowerCase().trim() == field,
        orElse: () => candidates.first,
      );

      fieldMapping[bestMatch] = field;
      usedFields.add(field);

      // Mark other candidates as skip to avoid duplicate mappings
      for (var candidate in candidates) {
        if (candidate != bestMatch) {
          fieldMapping[candidate] = 'Skip';
        }
      }
    }

    // Set remaining headers to Skip
    for (var header in widget.csvHeaders) {
      if (!fieldMapping.containsKey(header)) {
        fieldMapping[header] = 'Skip';
      }
    }
  }

  String? _findDefaultMapping(String header) {
    String normalized = header.toLowerCase().trim();

    // Exact match mappings
    Map<String, String> exactMappings = {
      'title': 'title',
      'particulars': 'title',
      'description': 'title',
      'narration': 'title',
      'details': 'title',
      'desc': 'description',
      'remarks': 'description',
      'notes': 'description',
      'debit': 'debit',
      'withdrawal': 'debit',
      'paid': 'debit',
      'payment': 'debit',
      'expense': 'debit',
      'dr': 'debit',
      'credit': 'credit',
      'deposit': 'credit',
      'received': 'credit',
      'income': 'credit',
      'cr': 'credit',
      'date': 'date',
      'transaction date': 'date',
      'txn date': 'date',
      'value date': 'date',
      'posting date': 'date',
      'trans date': 'date',
    };

    // Check for exact match first
    if (exactMappings.containsKey(normalized)) {
      return exactMappings[normalized];
    }

    // Then check for partial matches
    for (var entry in exactMappings.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  bool _validateMapping() {
    bool hasAmount = fieldMapping.values.contains('debit') ||
        fieldMapping.values.contains('credit');
    bool hasDate = fieldMapping.values.contains('date');
    return hasAmount && hasDate;
  }

  void _handleApply() {
    if (_validateMapping()) {
      widget.onMappingComplete(fieldMapping);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please map at least one amount field (debit/credit) and date'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getFieldDisplayName(String field) {
    switch (field) {
      case 'title':
        return 'Title/Particulars';
      case 'description':
        return 'Description';
      case 'debit':
        return 'Debit/Withdrawal';
      case 'credit':
        return 'Credit/Deposit';
      case 'date':
        return 'Transaction Date';
      default:
        return field;
    }
  }

  bool _isFieldAlreadyMapped(String field, String currentHeader) {
    if (field == 'Skip') return false;

    return fieldMapping.entries.any(
      (entry) => entry.key != currentHeader && entry.value == field,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map CSV Fields'),
        actions: [
          TextButton(
            onPressed: _handleApply,
            child: const Text(
              'Apply',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Match CSV columns to app fields',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Map each CSV column to the appropriate field. At least one amount field (debit or credit) and date are required.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          // Summary of current mapping
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Mapping Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...appFields.map((field) {
                  var mappedHeaders = fieldMapping.entries
                      .where((e) => e.value == field)
                      .map((e) => e.key)
                      .toList();

                  bool isRequired =
                      field == 'date' || field == 'debit' || field == 'credit';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          mappedHeaders.isEmpty
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle,
                          size: 16,
                          color: mappedHeaders.isEmpty && isRequired
                              ? Colors.orange
                              : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_getFieldDisplayName(field)}: ${mappedHeaders.isEmpty ? "Not mapped" : mappedHeaders.join(", ")}',
                            style: TextStyle(
                              fontSize: 13,
                              color: mappedHeaders.isEmpty && isRequired
                                  ? Colors.orange.shade900
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 32),
          ...widget.csvHeaders.map((header) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CSV Field: "$header"',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Map to: '),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: fieldMapping[header],
                              items: [
                                ...appFields.map((field) {
                                  bool alreadyMapped =
                                      _isFieldAlreadyMapped(field, header);
                                  return DropdownMenuItem(
                                    value: field,
                                    enabled: !alreadyMapped,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _getFieldDisplayName(field),
                                            style: TextStyle(
                                              color: alreadyMapped
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        if (alreadyMapped)
                                          const Text(
                                            '(already mapped)',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                                const DropdownMenuItem(
                                  value: 'Skip',
                                  child: Text('Skip This Field'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    fieldMapping[header] = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      if (fieldMapping[header] == 'debit' ||
                          fieldMapping[header] == 'credit' ||
                          fieldMapping[header] == 'date')
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.green,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Required field',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleApply,
        tooltip: 'Complete Mapping',
        icon: const Icon(Icons.check),
        label: const Text('Complete'),
      ),
    );
  }
}
