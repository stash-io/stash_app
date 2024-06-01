import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<ShadFormState>();
  bool obscure = true;

  void actionLogin() {
    if (formKey.currentState!.saveAndValidate()) {
      print('validation succeeded with ${formKey.currentState!.value}');
    } else {
      print('validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Scaffold(
      body: Center(
        child: ShadForm(
          key: formKey,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShadInputFormField(
                  id: 'username',
                  label: const Text('Email'),
                  placeholder: const Text('john@doe.com'),
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
                          onPressed: actionLogin,
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
    ));
  }
}
