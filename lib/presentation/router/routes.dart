import 'package:emi_manager/presentation/pages/emi_details_page.dart';
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
    return OnboardingScreen(); // Display the onboarding carousel
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
    return  HomePage();
  }
}

class NewEmiRoute extends GoRouteData {
  const NewEmiRoute({required this.emiType, this.emiId});
  final String emiType;
  final String? emiId; // Optional parameter for editing

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return NewEmiPage(emiType: emiType, emiId: emiId);
  }
}

@TypedGoRoute<EmiDetailsRoute>(
  path: '/emiDetails/:emiId',
)
class EmiDetailsRoute extends GoRouteData {
  const EmiDetailsRoute({required this.emiId});
  final String emiId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return EmiDetailsPage(emiId: emiId);
  }
}
