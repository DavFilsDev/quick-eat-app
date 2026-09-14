import 'package:flutter/material.dart';

import '../../../../../core/widgets/screen_placeholder.dart';

/// TODO(Dev 3 - feat/student-orders) : suivi temps réel des commandes de
/// l'étudiant connecté. Voir maquette `Commandes Étudiant`.
class StudentOrdersScreen extends StatelessWidget {
  const StudentOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(titre: 'Mes Commandes');
  }
}
