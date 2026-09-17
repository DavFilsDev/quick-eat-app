import 'package:flutter/material.dart';

import 'quick_eat_app_bar.dart';

/// Placeholder générique pour un écran pas encore implémenté par le dev
/// responsable. Chaque stub de `features/**/presentation/screens/` doit
/// être remplacé par le vrai contenu — ne pas laisser ce widget en l'état
/// dans une PR de fin de sprint.
class ScreenPlaceholder extends StatelessWidget {
  final String titre;

  const ScreenPlaceholder({super.key, required this.titre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const QuickEatAppBar(),
      body: Center(child: Text('$titre — TODO')),
    );
  }
}
