import 'package:flutter/material.dart';
import 'package:rachas/app/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Center(
        child: FilledButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.home),
          child: const Text('Entrar'),
        ),
      ),
    );
  }
}
