
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:emi_manager/data/models/tag_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/logic/locale_provider.dart';
import 'package:emi_manager/presentation/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  // Hive.deleteBoxFromDisk('preferences');
  // Hive.deleteBoxFromDisk('emis');
  Hive.registerAdapter(EmiAdapter());
  Hive.registerAdapter(TagAdapter());
  await Hive.openBox<Emi>('emis');
  await Hive.openBox<Tag>('tags');

  var prefsBox = await Hive.openBox('preferences');

  bool isFirstRun = prefsBox.get('isFirstRun', defaultValue: true);

  runApp(ProviderScope(
    child: MainApp(isFirstRun: isFirstRun),
  ));
}

class MainApp extends ConsumerWidget {
  final bool isFirstRun;
  const MainApp({
    super.key,
    required this.isFirstRun,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider);

    return MaterialApp.router(
      locale: locale,
      supportedLocales: const [
        Locale('en'), // English
        Locale('hi'), // Hindi
        Locale('te') // Telugu
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
          useMaterial3: true, colorScheme: _colorScheme(Brightness.light)),
      darkTheme: ThemeData(
          useMaterial3: true, colorScheme: _colorScheme(Brightness.dark)),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

ColorScheme _colorScheme(Brightness brightness) =>
    ColorScheme.fromSeed(seedColor: Colors.cyan, brightness: brightness);
