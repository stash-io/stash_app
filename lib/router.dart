import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app/pages/home.dart';
import 'package:stash_app/pages/login.dart';
import 'package:stash_app/pages/onboarding.dart';
import 'package:stash_app/pages/register.dart';
import 'package:stash_app/store.dart';

String? goToOnboardingIfNotLoggedIn(BuildContext context, GoRouterState state) {
  final user = context.get<Signal<User?>>();
  if (user.value == null) {
    return '/onboarding';
  }

  return null;
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      redirect: goToOnboardingIfNotLoggedIn,
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);
