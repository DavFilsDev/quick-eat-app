import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../models/enums/user_role.dart';
import '../../../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authRepository = FirebaseAuthRepository();
  final _userRepository = FirestoreUserRepository();

  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.student;
  bool _isLoading = false;

  Future<void> _creerCompte() async {
    setState(() => _isLoading = true);
    try {
      final credential = await _authRepository.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await _userRepository.creerOuMettreAJourUtilisateur(
        UserModel(
          idUser: credential.user!.uid,
          prenoms: _nomController.text.trim(),
          nom: '',
          email: _emailController.text.trim(),
          role: _role,
          campus: 'Campus UAC - Abomey-Calavi',
          dateCreation: DateTime.now(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Création échouée.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QuickEat - Créer un compte')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SegmentedButton<UserRole>(
              segments: const [
                ButtonSegment(value: UserRole.student, label: Text('Étudiant')),
                ButtonSegment(
                  value: UserRole.merchant,
                  label: Text('Commerçant'),
                ),
              ],
              selected: {_role},
              onSelectionChanged: (selection) =>
                  setState(() => _role = selection.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom complet'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Adresse email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe (6 caractères min.)',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _creerCompte,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Créer mon compte'),
            ),
          ],
        ),
      ),
    );
  }
}
