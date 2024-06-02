import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stash_app/components/scrollable.dart';
import 'package:stash_app/services/auth.dart';
import 'package:stash_app/store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<ShadFormState>();
  bool obscure = true;

  var email = "";
  var password = "";

  @override
  Widget build(BuildContext context) {
    final user = context.get<Signal<User?>>();

    Future<void> login() async {
      if (!formKey.currentState!.saveAndValidate()) {
        return;
      }

      try {
        user.value = await authLogin(email, password);

        if (mounted) {
          ShadToaster.of(context).show(
            ShadToast(
              title: const Text('Sesión iniciada correctamente.'),
              description: Text('Bienvenido ${user.value?.username}!'),
            ),
          );

          context.go("/");
        }
      } catch (e) {
        if (mounted) {
          ShadToaster.of(context).show(
            ShadToast(
              title: const Text('Ha habido un error en el servidor.'),
              description: Text(e.toString()),
            ),
          );
        }
      }
    }

    return ScrollScreen(
      child: Center(
        child: ShadForm(
          key: formKey,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Inicio sesión",
                  style: ShadTheme.of(context).textTheme.h1,
                ),
                const SizedBox(height: 32),
                ShadInputFormField(
                  id: 'email',
                  label: const Text('Email'),
                  placeholder: const Text('john@doe.com'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => setState(() {
                    email = value;
                  }),
                  validator: (v) {
                    if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(v)) {
                      return 'El email debe ser válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                ShadInputFormField(
                  id: 'password',
                  label: const Text('Contraseña'),
                  placeholder: const Text('•••••••'),
                  obscureText: obscure,
                  onChanged: (value) => setState(() {
                    password = value;
                  }),
                  prefix: const Padding(
                    padding: EdgeInsets.only(right: 16.0, left: 2.0),
                    child: ShadImage.square(size: 16, LucideIcons.lock),
                  ),
                  validator: (v) {
                    if (v.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres.';
                    }
                    return null;
                  },
                  suffix: ShadButton(
                    width: 24,
                    height: 24,
                    padding: EdgeInsets.zero,
                    decoration: const ShadDecoration(
                      secondaryBorder: ShadBorder.none,
                      secondaryFocusedBorder: ShadBorder.none,
                    ),
                    icon: ShadImage.square(
                      size: 16,
                      obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                    ),
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        ShadButton(
                          text: const Text('Iniciar Sesión'),
                          onPressed: login,
                          width: double.infinity,
                        ),
                        ShadButton.link(
                          text: const Text('No tienes cuenta? Crear una.'),
                          onPressed: () {
                            context.go('/register');
                          },
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
