import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/data/models/tag_model.dart';

class HomeStateModel {
  List<Emi> emis;
  List<Tag> selectedTags;

  HomeStateModel({
    required this.emis,
    required this.selectedTags,
  });

  HomeStateModel copyWith({List<Emi>? emis, List<Tag>? selectedTags}) =>
      HomeStateModel(
        emis: emis ?? this.emis,
        selectedTags: selectedTags ?? this.selectedTags,
      );
}
