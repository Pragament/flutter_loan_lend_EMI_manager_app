import 'package:emi_manager/data/models/tag_model.dart';
import 'package:emi_manager/presentation/pages/home/logic/home_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagsStrip extends ConsumerWidget {
  const TagsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateNotifierProvider);
    final selectedTags = homeState.selectedTags;

    // Gather all tags from EMIs
    final allTags = homeState.emis.expand((emi) => emi.tags).toList();

    // Normalize and remove duplicates (case & space insensitive)
    final Map<String, Tag> uniqueMap = {};
    for (final tag in allTags) {
      final key = tag.name.trim().toLowerCase();
      // Keep first unique tag, including ID
      uniqueMap.putIfAbsent(
        key,
            () => Tag(
          id: tag.id, // ✅ required id included here
          name: tag.name.trim(),
        ),
      );
    }

    final uniqueTags = uniqueMap.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // ----------- "All" Chip -----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: SizedBox(
              height: 35,
              child: FilterChip(
                padding: const EdgeInsets.all(4.0),
                showCheckmark: false,
                label: Row(
                  children: [
                    Icon(
                      selectedTags.isEmpty
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const Text(' All', style: TextStyle(fontSize: 16)),
                  ],
                ),
                selected: selectedTags.isEmpty,
                onSelected: (_) {
                  ref
                      .read(homeStateNotifierProvider.notifier)
                      .updateTagSelection([]);
                },
              ),
            ),
          ),

          // ----------- Dynamic Tag Chips -----------
          ...uniqueTags.map((tag) {
            final normalized = tag.name.trim().toLowerCase();

            final isSelected = selectedTags
                .any((t) => t.name.trim().toLowerCase() == normalized);

            return Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: SizedBox(
                height: 35,
                child: FilterChip(
                  padding: const EdgeInsets.all(4.0),
                  showCheckmark: false,
                  label: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 20,
                      ),
                      Text(' ${tag.name}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    final notifier =
                    ref.read(homeStateNotifierProvider.notifier);

                    // Build a normalized name set for selected tags
                    final selectedNames = <String>{
                      for (var t in selectedTags) t.name.trim().toLowerCase()
                    };

                    if (selected) {
                      selectedNames.add(normalized);
                    } else {
                      selectedNames.remove(normalized);
                    }

                    // Map normalized names back to full Tag objects
                    final updatedList = selectedNames
                        .map((name) => uniqueMap[name]!)
                        .toList();

                    notifier.updateTagSelection(updatedList);
                  },
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
