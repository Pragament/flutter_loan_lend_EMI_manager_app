// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:emi_manager/data/models/tag_model.dart';
import 'package:flutter/material.dart';
import 'package:emi_manager/presentation/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart'; // Import Lottie
import 'dart:async'; // Import Timer functionality

import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/data/models/rounding_settings.dart'; // Import rounding settings
import 'package:emi_manager/logic/locale_provider.dart';
import 'package:emi_manager/presentation/router/router.dart';
import 'package:showcaseview/showcaseview.dart';

import 'data/models/transaction_model.dart';
import 'package:emi_manager/presentation/pages/eula_page.dart';
import 'package:emi_manager/logic/eula_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  // Hive.deleteBoxFromDisk('preferences');
  // Hive.deleteBoxFromDisk('emis');

  // Register all adapters
  Hive.registerAdapter(EmiAdapter());
  Hive.registerAdapter(TagAdapter());
  Hive.registerAdapter(TransactionAdapter());

  // Register rounding settings adapters
  Hive.registerAdapter(RoundingSettingsAdapter());
  Hive.registerAdapter(PrecisionTypeAdapter());
  Hive.registerAdapter(RoundingMethodAdapter());

  await Hive.openBox<Emi>('emis');
  await Hive.openBox<Tag>('tags');
  await Hive.openBox<Transaction>('transactions');

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
    return ShowCaseWidget(
      builder: (context) => MaterialApp(
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true, colorScheme: _colorScheme(Brightness.light)),
        darkTheme: ThemeData(
            useMaterial3: true, colorScheme: _colorScheme(Brightness.dark)),
        home: SplashScreen(isFirstRun: isFirstRun), // Set SplashScreen as home
      ),
    );
  }
}

ColorScheme _colorScheme(Brightness brightness) =>
    ColorScheme.fromSeed(seedColor: Colors.cyan, brightness: brightness);

// Splash Screen Widget
class SplashScreen extends StatefulWidget {
  final bool isFirstRun;

  const SplashScreen({super.key, required this.isFirstRun});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    bool showEula = await EulaProvider.needsEulaAcceptance();
    if (showEula && !widget.isFirstRun) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EulaPage(
            onAccepted: () async {
              final activeEula = await EulaProvider.getActiveEula();
              await EulaProvider.acceptEula(activeEula?['version']);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MainAppContent(isFirstRun: widget.isFirstRun),
                ),
              );
            },
            onDeclined: () {
              // Block usage or exit app
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'EULA Declined',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'You must accept the EULA to use this app.',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainAppContent(isFirstRun: widget.isFirstRun),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
            'assets/animations/coin_stack.json'), // Lottie animation
      ),
    );
  }
}

// Main App Content after SplashScreen
class MainAppContent extends ConsumerWidget {
  final bool isFirstRun;
  const MainAppContent({
    super.key,
    required this.isFirstRun,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider);
    return ShowCaseWidget(
      builder: (context) => MaterialApp.router(
        locale: locale,
        supportedLocales: const [
          Locale('en'), // English
          Locale('hi'), // Hindi
          Locale('te'), // Telugu
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: _colorScheme(Brightness.light),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: _colorScheme(Brightness.dark),
        ),
        routerConfig: ref.watch(routerProvider), // Use existing routing logic
      ),
    );
  }
}
