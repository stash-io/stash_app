import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String username;
  String email;

  User(this.username, this.email);

  User.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        email = json['email'];

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
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
