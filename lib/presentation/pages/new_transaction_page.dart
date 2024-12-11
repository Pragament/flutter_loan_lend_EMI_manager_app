import 'package:emi_manager/logic/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/transaction_model.dart';

class NewTransactionPage extends ConsumerStatefulWidget {
  final String type;
  final String emiId;
  const NewTransactionPage({super.key, required this.type, required this.emiId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends ConsumerState<NewTransactionPage> {
  bool isIncome = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String get _formattedDate => DateFormat('dd/MM/yyyy').format(_selectedDate);
  String get _formattedTime => _selectedTime.format(context);

  // Save transaction to Hive
  void _saveTransaction() {
    if (_formKey.currentState?.validate() ?? false) {
      final transactionId = const Uuid().v4();

      final transaction = Transaction(
        id: transactionId,
        title: _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        type: widget.type,
        datetime: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        loanLendId: widget.emiId,
      );

      ref.read(transactionsNotifierProvider.notifier).add(transaction);
      print("Transaction saved in Hive: ${widget.emiId}");

      Navigator.pop(context);
    }
  }

  void _pickDate() async {
    final pickedDate = await Picker.pickDate(context, _selectedDate);
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _pickTime() async {
    final pickedTime = await Picker.pickTime(context, _selectedTime);
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              widget.type == 'CR'
              ? ChoiceChip(
                label: const Text('Income'),
                selected: isIncome,
                onSelected: (selected) {
                  setState(() {
                    isIncome = true;
                  });
                },
                selectedColor: Colors.deepPurple,
                labelStyle: TextStyle(
                  color: isIncome ? Colors.white : Colors.deepPurple,
                ),
                backgroundColor: Colors.white,
                shape: const StadiumBorder(
                  side: BorderSide(color: Colors.deepPurple),
                ),
              )
              : ChoiceChip(
                label: const Text('Expense'),
                selected: isIncome,
                onSelected: (selected) {
                  setState(() {
                    isIncome = true;
                  });
                },
                selectedColor: Colors.deepPurple,
                labelStyle: TextStyle(
                  color: isIncome ? Colors.white : Colors.deepPurple,
                ),
                backgroundColor: Colors.white,
                shape: const StadiumBorder(
                  side: BorderSide(color: Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  filled: true,
                  fillColor: Colors.deepPurple[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: Colors.deepPurple[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  labelText: '0.0',
                  filled: true,
                  fillColor: Colors.deepPurple[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _pickDate,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.deepPurple),
                        const SizedBox(width: 5),
                        Text(
                          _formattedDate,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickTime,
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.deepPurple),
                        const SizedBox(width: 5),
                        Text(
                          _formattedTime,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class Picker {
  static Future<DateTime?> pickDate(BuildContext context, DateTime initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  static Future<TimeOfDay?> pickTime(BuildContext context, TimeOfDay initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }
}


// Row(
//   mainAxisAlignment: MainAxisAlignment.start,
//   children: [
//     ChoiceChip(
//       label: Text('Income'),
//       selected: isIncome,
//       onSelected: (selected) {
//         setState(() {
//           isIncome = true;
//         });
//       },
//       selectedColor: Colors.deepPurple,
//       labelStyle: TextStyle(
//         color: isIncome ? Colors.white : Colors.deepPurple,
//       ),
//       backgroundColor: Colors.white,
//       shape: StadiumBorder(
//         side: BorderSide(color: Colors.deepPurple),
//       ),
//     ),
//     SizedBox(width: 10),
//     ChoiceChip(
//       label: Text('Expense'),
//       selected: !isIncome,
//       onSelected: (selected) {
//         setState(() {
//           isIncome = false;
//         });
//       },
//       selectedColor: Colors.deepPurple,
//       labelStyle: TextStyle(
//         color: !isIncome ? Colors.white : Colors.deepPurple,
//       ),
//       backgroundColor: Colors.white,
//       shape: StadiumBorder(
//         side: BorderSide(color: Colors.deepPurple),
//       ),
//     ),
//   ],
// ),