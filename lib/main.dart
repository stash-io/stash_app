import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stash_app/config.dart';
import 'package:stash_app/router.dart';
import 'package:stash_app/store.dart';

void main() {
  Stripe.publishableKey = config['stripe_public_key']!;
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => Store(
        shadApp: ShadApp.router(
          routerConfig: router,
          darkTheme: ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: const ShadSlateColorScheme.dark(),
          ),
        ),
      );
}
