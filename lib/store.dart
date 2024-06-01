import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class User {
  String username;
  String email;

  User(this.username, this.email);
}

class Store extends StatelessWidget {
  const Store({super.key, required this.shadApp});

  final ShadApp shadApp;

  @override
  Widget build(BuildContext context) {
    return Solid(
      providers: [
        Provider<Signal<User?>>(
          create: () => Signal(null),
        ),
      ],
      builder: (context) {
        return shadApp;
      },
    );
  }
}
