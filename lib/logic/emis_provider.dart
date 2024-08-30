import 'package:emi_manager/data/models/emi_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'emis_provider.g.dart';

@riverpod
class EmisNotifier extends _$EmisNotifier {
  late Box<Emi> _box;

  @override
  List<Emi> build() {
    _box = Hive.box<Emi>('emis');
    return _box.values.toList();
  }

  Future<void> add(Emi emi) async {
    await _box.put(emi.id, emi);
    state = [...state, emi];
  }

  Future<void> remove(Emi emi) async {
    await _box.delete(emi.id);
    state = state.where((item) => item.id != emi.id).toList();
  }

  Future<void> update(Emi emi) async {
    await _box.put(emi.id, emi);

    state = [
      for (final existingEmi in state)
        if (existingEmi.id == emi.id) emi else existingEmi
    ];
  }
}
