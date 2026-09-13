import 'package:flutter/material.dart';

import '../../../../core/widgets/screen_placeholder.dart';

/// TODO(Dev 1 - feat/auth-onboarding) : écran de création de compte
/// (toggle Étudiant/Commerçant, nom, téléphone, campus, email, mot de
/// passe). Voir maquette `creation-de-compte`.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(titre: 'Créer un compte');
  }
}
