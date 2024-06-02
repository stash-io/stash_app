import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stash_app/components/scrollable.dart';
import 'package:stash_app/services/auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<ShadFormState>();
  bool obscure = true;

  var username = "";
  var email = "";
  var password = "";
  var repeatPassword = "";

  Future<void> register() async {
    if (!formKey.currentState!.saveAndValidate()) {
      return;
    }

    try {
      await authRegister(username, email, password);
      if (mounted) {
        context.go("/login");
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

  @override
  Widget build(BuildContext context) {
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
                  "Registrarse",
                  style: ShadTheme.of(context).textTheme.h1,
                ),
                const SizedBox(height: 32),
                ShadInputFormField(
                  id: 'username',
                  label: const Text('Nombre de usuario'),
                  placeholder: const Text('john doe'),
                  onChanged: (value) => setState(() {
                    username = value;
                  }),
                  validator: (v) {
                    if (v.isEmpty) {
                      return 'Introduce un nombre de usuario.';
                    }

                    if (v.length > 20) {
                      return 'El nombre de usuario no puede tener mas de 20 caracteres.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 8),
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
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'repeatPassword',
                  label: const Text('Repetir contraseña'),
                  placeholder: const Text('•••••••'),
                  obscureText: obscure,
                  onChanged: (value) => setState(() {
                    repeatPassword = value;
                  }),
                  prefix: const Padding(
                    padding: EdgeInsets.only(right: 16.0, left: 2.0),
                    child: ShadImage.square(size: 16, LucideIcons.lock),
                  ),
                  validator: (v) {
                    if (v != password || v.isEmpty) {
                      return 'La contraseña debe ser la misma.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        ShadButton(
                          text: const Text('Crear cuenta'),
                          onPressed: register,
                          width: double.infinity,
                        ),
                        ShadButton.link(
                          text: const Text('Ya tienes cuenta? Iniciar sesión.'),
                          onPressed: () {
                            context.go('/login');
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
