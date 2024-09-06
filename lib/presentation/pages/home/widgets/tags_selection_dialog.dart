// ignore_for_file: use_build_context_synchronously

import 'package:emi_manager/data/models/tag_model.dart';
import 'package:emi_manager/logic/tags_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class TagsSelectionDialog extends ConsumerStatefulWidget {
  const TagsSelectionDialog({super.key, required this.selectedTags});
  final List<Tag> selectedTags;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TagsSelectionDialogState();
}

class _TagsSelectionDialogState extends ConsumerState<TagsSelectionDialog> {
  List<Tag> selectedTags = [];

  @override
  void initState() {
    selectedTags = widget.selectedTags;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final allTags = ref.watch(tagsNotifierProvider);

    return SizedBox(
      height: 500,
      width: 400,
      child: AlertDialog(
        scrollable: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text('Select Tags:'),
            IconButton.filledTonal(
              onPressed: () {
                final tagNameC = TextEditingController();
                final formKey = GlobalKey<FormState>();

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Enter tag name",
                        textAlign: TextAlign.center),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    backgroundColor: Theme.of(context).dialogBackgroundColor,
                    titlePadding: const EdgeInsets.only(top: 27),
                    insetPadding: EdgeInsets.zero,
                    contentPadding: const EdgeInsets.only(top: 10),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    content: SizedBox(
                      height: 125,
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(5)),
                                child: TextFormField(
                                  controller: tagNameC,
                                  autofocus: true,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  cursorColor: Theme.of(context).focusColor,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Cannot be empty';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.tag),
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                elevation: 0.0,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  await ref
                                      .read(tagsNotifierProvider.notifier)
                                      .add(Tag(
                                          id: const Uuid().v1(),
                                          name: tagNameC.text));
                                  context.pop();
                                }
                              },
                              child: const Text('Create'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        content: allTags.isEmpty
            ? const Text('No tags exist.\nTap + icon to create a new tag.')
            : SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    allTags.length,
                    (index) {
                      final tag = allTags.elementAt(index);

                      return CheckboxListTile(
                        title: Text(tag.name),
                        value: selectedTags.map((e) => e.id).contains(tag.id),
                        onChanged: (enabled) => setState(
                          () => enabled ?? false
                              ? selectedTags.add(tag)
                              : selectedTags.remove(tag),
                        ),
                      );
                    },
                  ),
                ),
              ),
        actions: [
          FilledButton(
            onPressed: () => context.pop(selectedTags),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
