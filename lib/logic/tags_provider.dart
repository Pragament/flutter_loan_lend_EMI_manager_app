import 'package:emi_manager/data/models/tag_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tags_provider.g.dart';

@riverpod
class TagsNotifier extends _$TagsNotifier {
  late Box<Tag> _box;

  @override
  List<Tag> build() {
    _box = Hive.box<Tag>('tags');
    return _box.values.toList();
  }

  Future<void> add(Tag tag) async {
    await _box.put(tag.id, tag); // Save tag to Hive
    state = [...state, tag]; // Update state
  }

  Future<void> remove(Tag tag) async {
    await _box.delete(tag.id); // Remove tag from Hive
    state = state.where((item) => item.id != tag.id).toList(); // Update state
  }

  Future<void> update(Tag tag) async {
    await _box.put(tag.id, tag); // Update tag in Hive
    state = [
      for (final existingTag in state)
        if (existingTag.id == tag.id) tag else existingTag
    ]; // Update state
  }
}
