import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stash_app/store.dart';
import 'package:typewritertext/v3/typewriter.dart';

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
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ShadAvatar(
                          'assets/avatar.svg',
                          placeholder: Text(user.value?.username
                              .substring(0, 2)
                              .toUpperCase() as String),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TypeWriter.text(
                          "Hola, ${user.value?.username}",
                          style: ShadTheme.of(context).textTheme.large,
                          duration: const Duration(milliseconds: 50),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ShadButton(
                    size: ShadButtonSize.icon,
                    icon:
                        const ShadImage.square(size: 16, LucideIcons.settings),
                    onPressed: () => showShadDialog(
                      context: context,
                      builder: (context) => ShadDialog(
                        title: const Text(
                            textAlign: TextAlign.left, 'Preferencias'),
                        description: const Text(
                            textAlign: TextAlign.left,
                            "Aquí puedes gestionar las preferecias de la aplicación."),
                        content: Container(
                          width: 375,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ShadInputFormField(
                                  id: 'username',
                                  label: const Text('Nombre de usuario'),
                                  initialValue: user.value?.username,
                                  enabled: false,
                                ),
                                ShadInputFormField(
                                  id: 'email',
                                  label: const Text('Email'),
                                  initialValue: user.value?.email,
                                  enabled: false,
                                ),
                              ]),
                        ),
                        actions: [
                          ShadButton.ghost(
                            text: const Text('Cerrar'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          ShadButton.destructive(
                            text: const Text("Cerrar sesión."),
                            onPressed: () {
                              user.value = null;
                              context.go('/login');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Tus links",
              style: ShadTheme.of(context).textTheme.h2,
            ),
            const Expanded(
              child: SizedBox(height: 16),
            ),
            const SizedBox(height: 16)
          ],
        ),
      ),
    );
  }
}
