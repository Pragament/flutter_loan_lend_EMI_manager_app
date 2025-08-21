import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/data/models/tag_model.dart';
import 'package:emi_manager/logic/emis_provider.dart';
import 'package:emi_manager/presentation/pages/home/logic/home_state_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_state_provider.g.dart';

@riverpod
class HomeStateNotifier extends _$HomeStateNotifier {
  late List<Emi> allEmis = [];

  @override
  HomeStateModel build() {
    allEmis = ref.watch(emisNotifierProvider);
    return HomeStateModel(
      emis: allEmis,
      selectedTags: [],
    );
  }

  void updateTagSelection(List<Tag> selectedTags) {
    List<Emi> emisResult = selectedTags.isEmpty
        ? List.from(allEmis)
        : allEmis
            .where((emi) => emi.tags.any(
                (emiTag) => selectedTags.map((e) => e.id).contains(emiTag.id)))
            .toList();

    state = state.copyWith(emis: emisResult, selectedTags: selectedTags);
  }

  void removeEmi(String id) {}
}
