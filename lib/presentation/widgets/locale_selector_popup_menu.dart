import 'package:emi_manager/logic/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleSelectorPopupMenu extends ConsumerWidget {
  const LocaleSelectorPopupMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      onSelected: (Locale locale) {
        ref.read(localeNotifierProvider.notifier).changeLanguage(locale);
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<Locale>(
          value: Locale('en'),
          child: Text('English'),
        ),
        const PopupMenuItem<Locale>(
          value: Locale('te'),
          child: Text('Telugu'),
        ),
        const PopupMenuItem<Locale>(
          value: Locale('hi'),
          child: Text('Hindi'),
        ),
      ],
    );
  }
}
