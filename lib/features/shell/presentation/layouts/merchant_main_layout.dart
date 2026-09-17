import 'package:flutter/material.dart';

import '../../../orders/presentation/merchant/screens/merchant_home_screen.dart';
import '../../../profile/presentation/screens/merchant_profile_screen.dart';
import '../widgets/quick_eat_bottom_nav.dart';
import 'main_layout.dart';

/// Coquille de l'espace Commerçant : 2 onglets [Accueil, Profil] portés
/// par un `IndexedStack` (état conservé entre les onglets).
class MerchantMainLayout extends StatelessWidget {
  const MerchantMainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      pages: [MerchantHomeScreen(), MerchantProfileScreen()],
      navItems: [
        QuickEatNavItem(
          label: 'Accueil',
          iconInactif: Icons.storefront_outlined,
          iconActif: Icons.storefront,
        ),
        QuickEatNavItem(
          label: 'Profil',
          iconInactif: Icons.person_outline,
          iconActif: Icons.person,
        ),
      ],
    );
  }
}
