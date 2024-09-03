// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $onboardingRoute,
      $homeRoute,
      $emiDetailsRoute,
    ];

RouteBase get $onboardingRoute => GoRouteData.$route(
      path: '/onboarding',
      factory: $OnboardingRouteExtension._fromState,
    );

extension $OnboardingRouteExtension on OnboardingRoute {
  static OnboardingRoute _fromState(GoRouterState state) =>
      const OnboardingRoute();

  String get location => GoRouteData.$location(
        '/onboarding',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/',
      factory: $HomeRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'newEmi/:emiType',
          factory: $NewEmiRouteExtension._fromState,
        ),
      ],
    );

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $NewEmiRouteExtension on NewEmiRoute {
  static NewEmiRoute _fromState(GoRouterState state) => NewEmiRoute(
        emiType: state.pathParameters['emiType']!,
        emiId: state.uri.queryParameters['emi-id'],
      );

  String get location => GoRouteData.$location(
        '/newEmi/${Uri.encodeComponent(emiType)}',
        queryParams: {
          if (emiId != null) 'emi-id': emiId,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $emiDetailsRoute => GoRouteData.$route(
      path: '/emiDetails/:emiId',
      factory: $EmiDetailsRouteExtension._fromState,
    );

extension $EmiDetailsRouteExtension on EmiDetailsRoute {
  static EmiDetailsRoute _fromState(GoRouterState state) => EmiDetailsRoute(
        emiId: state.pathParameters['emiId']!,
      );

  String get location => GoRouteData.$location(
        '/emiDetails/${Uri.encodeComponent(emiId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
