import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  int id;
  String username;
  String email;
  String token;
  String role;
  int? reminderDayOfWeek;

  User(this.id, this.username, this.email, this.token, this.role,
      this.reminderDayOfWeek);

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        email = json['email'],
        token = json['token'],
        role = json['role'],
        reminderDayOfWeek = json['reminderDayOfWeek'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'token': token,
      'role': role,
      'reminderDayOfWeek': reminderDayOfWeek,
    };
  }
}

class Store extends StatelessWidget {
  const Store({super.key, required this.shadApp});

  final ShadApp shadApp;

  @override
  Widget build(BuildContext context) {
    return Solid(
      providers: [
        Provider<Signal<User?>>(
          create: () {
            return Signal(null);
          },
        ),
      ],
      builder: (context) {
        // Descomentar para limpiar el usuario al iniciar la app
        // SharedPreferences.getInstance().then(
        //   (prefs) {
        //     prefs.clear();
        //   },
        // );

        final user = context.get<Signal<User?>>();

        user.observe((previousUser, newUser) {
          () async {
            if (newUser == null) {
              (await SharedPreferences.getInstance()).remove('user');
              return;
            }

            (await SharedPreferences.getInstance())
                .setString('user', jsonEncode(newUser));
          }();
        });

        return shadApp;
      },
    );
  }
}
