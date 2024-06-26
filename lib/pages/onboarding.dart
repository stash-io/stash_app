import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:typewritertext/v3/typewriter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 96),
            Text(
              "Bienvenido a Stash",
              style: ShadTheme.of(context).textTheme.h1,
            ),
            const SizedBox(height: 16),
            TypeWriter.text(
              "Gestiona tu backlog de articulos, paginas web e ideas de la forma mas eficaz e intuitiva.",
              style: ShadTheme.of(context).textTheme.p,
              duration: const Duration(milliseconds: 50),
            ),
            const Expanded(
              child: SizedBox(height: 16),
            ),
            ShadButton.link(
              text: const Text("Tengo cuenta, iniciar sesión."),
              width: double.infinity,
              onPressed: () => context.go('/login'),
            ),
            const SizedBox(height: 8),
            ShadButton(
              text: const Text("No tengo cuenta, crear una."),
              width: double.infinity,
              onPressed: () => context.go('/register'),
            ),
            const SizedBox(height: 16)
          ],
        ),
      ),
    );
  }
}
