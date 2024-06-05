import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stash_app/components/collections.dart';
import 'package:stash_app/components/links.dart';
import 'package:stash_app/components/scrollable.dart';
import 'package:stash_app/config.dart';
import 'package:stash_app/services/auth.dart';
import 'package:stash_app/services/payments.dart';
import 'package:stash_app/store.dart';
import 'package:typewritertext/v3/typewriter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      () async {
        final user = context.get<Signal<User?>>();

        if (user.value == null) {
          return;
        }

        try {
          user.value = await authRefresh(user.value!.token);
        } catch (e) {
          user.value = null;
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('El servidor no esta disponible.'),
              description: Text(
                  'Intentalo mas tarde o ponte en contacto con el administrador en: vgarciaf@hey.com'),
            ),
          );
          context.go('/login');
        }
      }();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.get<Signal<User?>>();

    return ScrollScreen(
      child: Padding(
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
                        child: GestureDetector(
                          child: ShadAvatar(
                            'assets/avatar.svg',
                            placeholder: Text(user.value?.username
                                .substring(0, 2)
                                .toUpperCase() as String),
                          ),
                          onTap: () {
                            final Uri url = Uri.parse(
                                "${config['backend_url']}/publish/links/list/user/${user.value?.id}");
                            launchUrl(url);
                          },
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
                        title: const Text(textAlign: TextAlign.left, 'Ajustes'),
                        description: const Text(
                            textAlign: TextAlign.left,
                            "Aquí puedes gestionar los ajustes de la aplicación."),
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
                                if (user.value?.role == 'free') ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'Suscripciones',
                                    style: ShadTheme.of(context).textTheme.h4,
                                  ),
                                  const SizedBox(height: 8),
                                  ShadButton(
                                    text: const Text(
                                        'Suscribirse al plan Básico - 1 €/mes'),
                                    onPressed: () => startSubscriptionPayment(
                                        user.value as User, 1),
                                  ),
                                  ShadButton(
                                    text: const Text(
                                        'Suscribirse al plan Estandar - 3 €/mes'),
                                    onPressed: () => startSubscriptionPayment(
                                        user.value as User, 2),
                                  ),
                                  ShadButton(
                                      text: const Text(
                                          'Suscribirse al plan Premium - 6 €/mes'),
                                      onPressed: () async {
                                        await startSubscriptionPayment(
                                            user.value as User, 3);

                                        await Future.delayed(
                                            const Duration(seconds: 5));

                                        user.value = await authRefresh(
                                            user.value!.token);
                                      }),
                                ]
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
              "Tus colecciones",
              style: ShadTheme.of(context).textTheme.h2,
            ),
            const Collections(),
            const SizedBox(height: 18),
            Text(
              "Tus links",
              style: ShadTheme.of(context).textTheme.h2,
            ),
            const Links(),
          ],
        ),
      ),
    );
  }
}
