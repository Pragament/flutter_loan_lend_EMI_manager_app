import 'package:emi_manager/presentation/pages/home_page.dart';
import 'package:emi_manager/presentation/pages/new_emi_page.dart';
import 'package:emi_manager/presentation/pages/onboarding_carousel.dart'; // Import the OnboardingCarousel page
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

@TypedGoRoute<OnboardingRoute>(
  path: '/onboarding',
)
class OnboardingRoute extends GoRouteData {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OnboardingCarousel(); // Display the onboarding carousel
  }
}

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<NewEmiRoute>(path: 'newEmi/:emiType'),
  ],
)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}

class NewEmiRoute extends GoRouteData {
  const NewEmiRoute({required this.emiType});
  final String emiType;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return NewEmiPage(emiType: emiType);
  }
}
