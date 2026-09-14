import 'package:flutter/material.dart';

import '../../../../../core/widgets/screen_placeholder.dart';

/// TODO(Dev 4 - feat/merchant-orders-dashboard) : liste des commandes
/// reçues, triées de la plus ancienne à la plus récente. Voir maquette
/// `Accueil Commerçant`.
class MerchantHomeScreen extends StatelessWidget {
  const MerchantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(titre: 'Commandes Reçues');
  }
}
