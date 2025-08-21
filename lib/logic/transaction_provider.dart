import 'package:emi_manager/data/models/transaction_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_provider.g.dart';

@riverpod
class TransactionsNotifier extends _$TransactionsNotifier {
  late Box<Transaction> _box;

  @override
  List<Transaction> build() {
    _box = Hive.box<Transaction>('transactions');
    return _box.values.toList();
  }

  Future<void> add(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    state = [...state, transaction];
  }

  Future<void> remove(Transaction transaction) async {
    await _box.delete(transaction.id);
    state = state.where((item) => item.id != transaction.id).toList();
  }

  Future<void> update(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    state = [
      for (final existingTransaction in state)
        if (existingTransaction.id == transaction.id)
          transaction
        else
          existingTransaction
    ];
  }

  Future<Transaction?> getTransactionById(String id) async {
    return _box.get(id);
  }
}
