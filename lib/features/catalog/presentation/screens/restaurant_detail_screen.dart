import 'package:flutter/material.dart';

import '../../../../core/widgets/screen_placeholder.dart';

/// TODO(Dev 2 - feat/student-catalog) : détail restaurant (menu du
/// commerçant [idCommercant]). Voir maquette `Détail Restaurant`.
class RestaurantDetailScreen extends StatelessWidget {
  final String idCommercant;

  const RestaurantDetailScreen({super.key, required this.idCommercant});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(titre: 'Détail Restaurant');
  }
}
