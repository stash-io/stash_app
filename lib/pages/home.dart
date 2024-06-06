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
  final daysOfWeek = {
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábado',
    7: 'Domingo',
  };

  Future<void> subscribeToTier(int tier) async {
    final user = context.get<Signal<User?>>();
    final type = tier == 1
        ? 'Básico'
        : tier == 2
            ? 'Estandar'
            : 'Premium';

    await startSubscriptionPayment(user.value as User, tier);

    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        closeIcon: null,
        title: const Text('Procesando pago'),
        description: const Text(
            'Estamos procesando tu pago. Por favor, espera un momento...'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.6,
          ),
          child: const ShadProgress(),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 3), () async {
      var newUser = await authRefresh(user.value!.token);
      setState(() {
        user.value = newUser;
      });
      Navigator.of(context).pop(false);
      Navigator.of(context).pop(false);

      ShadToaster.of(context).show(
        ShadToast(
          title: Text('Tu subscripción $type se ha activado correctamente.'),
          description: const Text(
              '¡Gracias por confiar en nosotros! Ahora puedes disfrutar de todas las funcionalidades de la aplicación.'),
        ),
      );
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                ShadSelectFormField<String>(
                                  minWidth: 350,
                                  id: 'reminderDayOfWeek',
                                  label: const Text(
                                      'Día de la semana de recordatorio'),
                                  initialValue: user.value?.reminderDayOfWeek
                                          .toString() ??
                                      'null',
                                  placeholder:
                                      const Text("Selecciona dia de la semana"),
                                  options: [
                                    const ShadOption(
                                        value: 'null',
                                        child: Text('Desactivado')),
                                    ...daysOfWeek.entries.map((e) => ShadOption(
                                        value: e.key.toString(),
                                        child: Text(e.value)))
                                  ],
                                  selectedOptionBuilder: (context, value) =>
                                      Text(value == 'null'
                                          ? 'Desactivado'
                                          : daysOfWeek[int.parse(value)]!),
                                  onChanged: (String? value) => setState(() {
                                    if (value == 'null') {
                                      user.value!.reminderDayOfWeek = null;
                                    } else {
                                      user.value!.reminderDayOfWeek =
                                          int.parse(value!);
                                    }

                                    authUpdateReminderDayOfWeek(
                                        user.value!.token,
                                        user.value!.reminderDayOfWeek);
                                  }),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Gestiona tu suscripción',
                                  style: ShadTheme.of(context).textTheme.large,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '''Plan actual: ${user.value?.role == 'free' ? 'Plan gratuito' : user.value?.role == 'tier1' ? 'Básico' : user.value?.role == 'tier2' ? 'Estandar' : 'Premium'}''',
                                  style: ShadTheme.of(context).textTheme.muted,
                                ),
                                const SizedBox(height: 12),
                                if (user.value?.role != 'tier1')
                                  ShadButton(
                                    text: const Text(
                                        'Suscribirse al plan Básico - 1 €/mes'),
                                    onPressed: () => subscribeToTier(1),
                                  ),
                                if (user.value?.role != 'tier2')
                                  ShadButton(
                                    text: const Text(
                                        'Suscribirse al plan Estandar - 3 €/mes'),
                                    onPressed: () => subscribeToTier(2),
                                  ),
                                if (user.value?.role != 'tier3')
                                  ShadButton(
                                    text: const Text(
                                        'Suscribirse al plan Premium - 6 €/mes'),
                                    onPressed: () => subscribeToTier(3),
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
