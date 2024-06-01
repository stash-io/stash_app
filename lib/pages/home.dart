import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ShadButton(
        text: Text("Go to login"),
        onPressed: () => context.go('/login'),
      ),
    );
  }
}
