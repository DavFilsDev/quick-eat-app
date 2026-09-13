import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QuickEat - Authentification')),
      body: const Center(
        child: Text('Écran de choix de rôle (Student / Merchant) - TODO'),
      ),
    );
  }
}
