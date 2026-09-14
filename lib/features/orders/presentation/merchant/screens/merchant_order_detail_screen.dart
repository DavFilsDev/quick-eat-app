import 'package:flutter/material.dart';

import '../../../../../core/widgets/screen_placeholder.dart';

/// TODO(Dev 4 - feat/merchant-orders-dashboard) : détail d'une commande
/// [idCommande] + bouton d'action vers le statut suivant. Voir maquette
/// `Détails Commande Commerçant`.
class MerchantOrderDetailScreen extends StatelessWidget {
  final String idCommande;

  const MerchantOrderDetailScreen({super.key, required this.idCommande});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(titre: 'Détails Commande');
  }
}
