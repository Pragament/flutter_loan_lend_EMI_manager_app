import 'package:emi_manager/presentation/pages/error_page.dart';
import 'package:emi_manager/presentation/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Provider to determine if onboarding is needed
final firstRunProvider = Provider<bool>((ref) {
  final prefsBox = Hive.box('preferences');
  return prefsBox.get('isFirstRun', defaultValue: true);
});

final routerProvider = Provider<GoRouter>((ref) {
  final isFirstRun = ref.watch(firstRunProvider);

  return GoRouter(
    initialLocation: isFirstRun ? '/onboarding' : '/',
    errorPageBuilder: (context, state) =>
        const MaterialPage(child: ErrorPage()),
    routes: $appRoutes,
  );
});
