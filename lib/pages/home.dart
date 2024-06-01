import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stash_app/store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.get<Signal<User?>>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShadAvatar(
                      'assets/avatar.svg',
                      placeholder: Text(user.value?.username
                          .substring(0, 2)
                          .toUpperCase() as String),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Bienvenido ${user.value?.username}",
                      style: ShadTheme.of(context).textTheme.h3,
                    ),
                  ],
                ),
                ShadButton(
                  size: ShadButtonSize.icon,
                  icon: ShadImage.square(size: 16, LucideIcons.settings),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Gestiona tu backlog de articulos, paginas web e ideas de la forma mas eficaz e intuitiva.",
              style: ShadTheme.of(context).textTheme.p,
            ),
            const Expanded(
              child: SizedBox(height: 16),
            ),
            ShadButton(
              text: const Text("Cerrar sesión."),
              width: double.infinity,
              onPressed: () {
                user.value = null;
                context.go('/login');
              },
            ),
            const SizedBox(height: 16)
          ],
        ),
      ),
    );
  }
}
