import 'package:emi_manager/presentation/pages/error_page.dart';
import 'package:emi_manager/presentation/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider(
  (ref) {
    return GoRouter(
      errorPageBuilder: (context, state) =>
          const MaterialPage(child: ErrorPage()),
      initialLocation: '/',
      routes: $appRoutes,
    );
  },
);
