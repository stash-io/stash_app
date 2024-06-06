import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app/pages/collection.dart';
import 'package:stash_app/pages/home.dart';
import 'package:stash_app/pages/login.dart';
import 'package:stash_app/pages/onboarding.dart';
import 'package:stash_app/pages/register.dart';
import 'package:stash_app/services/auth.dart';
import 'package:stash_app/store.dart';

Future<void> loadUserFromStorage(user) async {
  final userEncoded = (await SharedPreferences.getInstance()).getString('user');
  if (userEncoded == null) {
    return;
  }

  final userDecoded = User.fromJson(jsonDecode(userEncoded));

  try {
    print(userDecoded.token);
    final refreshedUser = await authRefresh(userDecoded.token);
    if (refreshedUser == null) {
      return;
    }

    user.value = refreshedUser;
  } catch (e) {
    print(e);
    return;
  }
}

Future<String?> goToOnboardingIfNotLoggedIn(
    BuildContext context, GoRouterState state) async {
  final user = context.get<Signal<User?>>();
  if (user.value == null) {
    await loadUserFromStorage(user);

    if (user.value == null) {
      return '/onboarding';
    }
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
    GoRoute(
      path: '/collection',
      builder: (context, state) =>
          CollectionScreen(id: state.uri.queryParameters['id'] as String),
    ),
  ],
);
