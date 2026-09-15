import 'package:flutter/material.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../models/enums/user_role.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final AuthController _authController;

  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.student;
  String? _campusSelectionne;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(
      authRepository: FirebaseAuthRepository(),
      userRepository: FirestoreUserRepository(),
    )..addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _creerCompte() async {
    final success = await _authController.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nom: _nomController.text.trim(),
      prenoms: '',
      telephone: '',
      campus: _campusSelectionne ?? 'Campus UAC - Abomey-Calavi',
      role: _role,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.errorMessage ?? 'Création échouée.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_onControllerUpdate);
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _authController.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('QuickEat - Créer un compte')),
      body: SingleChildScrollView(
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
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Campus d'inscription",
                border: OutlineInputBorder(),
              ),
              value: _campusSelectionne,
              items: const [
                DropdownMenuItem(
                  value: 'Campus de Ngoa-Ekéllé',
                  child: Text('Campus de Ngoa-Ekéllé'),
                ),
                DropdownMenuItem(
                  value: 'Campus Ankatso',
                  child: Text('Campus Ankatso'),
                ),
                DropdownMenuItem(
                  value: 'Campus UAC - Abomey-Calavi',
                  child: Text('Campus UAC - Abomey-Calavi'),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _campusSelectionne = newValue;
                });
              },
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
              onPressed: isLoading ? null : _creerCompte,
              child: isLoading
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
