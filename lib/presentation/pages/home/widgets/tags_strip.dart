import 'package:emi_manager/data/models/tag_model.dart';
import 'package:emi_manager/logic/tags_provider.dart';
import 'package:emi_manager/presentation/pages/home/logic/home_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagsStrip extends ConsumerWidget {
  const TagsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTags = ref.watch(tagsNotifierProvider);
    final selectedTags = ref.watch(homeStateNotifierProvider).selectedTags;

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: SizedBox(
              height: 35,
              child: FittedBox(
                  fit: BoxFit.contain,
                  child: FilterChip(
                    padding: const EdgeInsets.all(4.0),
                    showCheckmark: false,
                    label: Row(
                      children: [
                        Icon(selectedTags.isEmpty
                            ? Icons.check_box
                            : Icons.check_box_outline_blank),
                        const Text(' All', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    selected: selectedTags.isEmpty,
                    onSelected: (_) => ref
                        .read(homeStateNotifierProvider.notifier)
                        .updateTagSelection([]),
                  ))),
        ),
        SingleChildScrollView(
          child: Row(
            children: List.generate(
              allTags.length,
              (index) {
                final tag = allTags.elementAt(index);
                final isSelected =
                    selectedTags.map((e) => e.name).contains(tag.name);
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: SizedBox(
                    height: 35,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: FilterChip(
                        padding: const EdgeInsets.all(4.0),
                        showCheckmark: false,
                        label: Row(
                          children: [
                            Icon(isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank),
                            Text(' ${tag.name}',
                                style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          final tags = List<Tag>.from(selectedTags);
                          if (selected) {
                            tags.add(tag);
                          } else {
                            tags.remove(tag);
                          }
                          ref
                              .read(homeStateNotifierProvider.notifier)
                              .updateTagSelection(tags);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
