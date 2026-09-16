import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../models/enums/user_role.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_toggle.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final AuthController _authController;

  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomsController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _role = UserRole.student;
  String? _campusSelectionne = 'Campus UAC - Abomey-Calavi';
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _authController = AuthController(
      authRepository: FirebaseAuthRepository(),
      userRepository: FirestoreUserRepository(),
    )..addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _creerCompte() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _authController.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nom: _nomController.text.trim(),
      prenoms: _prenomsController.text.trim(),
      telephone: _telephoneController.text.trim(),
      campus: _campusSelectionne ?? 'Campus UAC - Abomey-Calavi',
      role: _role,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.errorMessage ?? 'Création échouée.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int get _passwordStrength {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    if (p.length < 6) return 1;
    final hasDigits = p.contains(RegExp(r'[0-9]'));
    final hasUpperOrSpecial = p.contains(RegExp(r'[A-Z!@#$%^&*(),.?":{}|<>]'));
    if (p.length >= 8 && hasDigits && hasUpperOrSpecial) return 3;
    return 2;
  }

  Widget _buildPasswordStrengthIndicator() {
    final strength = _passwordStrength;
    if (strength == 0) return const SizedBox.shrink();

    final labels = ['', 'Faible', 'Moyen', 'Fort'];
    final colors = [
      Colors.grey.shade300,
      Colors.red,
      Colors.orange,
      Colors.green,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          for (int i = 1; i <= 3; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= strength
                      ? colors[strength]
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < 3) const SizedBox(width: 6),
          ],
          const SizedBox(width: 12),
          Text(
            labels[strength],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors[strength],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _authController.removeListener(_onControllerUpdate);
    _nomController.dispose();
    _prenomsController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _authController.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- En-tête de la Maquette ---
                  Text(
                    'QuickEat',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bienvenu parmi nous ! 👋',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Commande en quelques minutes ou commence à vendre sur ton campus.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Toggle Étudiant / Commerçant
                  RoleToggle(
                    selectedRole: _role,
                    onRoleChanged: (newRole) => setState(() => _role = newRole),
                  ),
                  const SizedBox(height: 16),

                  AuthTextField(
                    controller: _nomController,
                    label: 'Nom',
                    prefixIcon: Icons.person_outline,
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _prenomsController,
                    label: 'Prénoms',
                    prefixIcon: Icons.person_outline,
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Prénom requis' : null,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _telephoneController,
                    label: 'Téléphone',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (val) => (val == null || val.isEmpty)
                        ? 'Téléphone requis'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _campusSelectionne,
                    decoration: const InputDecoration(
                      labelText: 'Ton Campus principal',
                      prefixIcon: Icon(Icons.school_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Campus UAC - Abomey-Calavi',
                        child: Text('Campus UAC - Abomey-Calavi'),
                      ),
                      DropdownMenuItem(
                        value: 'Campus de Ngoa-Ekéllé',
                        child: Text('Campus de Ngoa-Ekéllé'),
                      ),
                      DropdownMenuItem(
                        value: 'Campus Ankatso',
                        child: Text('Campus Ankatso'),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => _campusSelectionne = val),
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email universitaire ou perso',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => (val == null || !val.contains('@'))
                        ? 'Email invalide'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (val) => (val == null || val.length < 6)
                        ? 'Min. 6 caractères'
                        : null,
                  ),
                  _buildPasswordStrengthIndicator(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : _creerCompte,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Créer mon compte',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Déjà inscrit ? '),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
