import 'package:flutter/material.dart';

import '../../../menu_management/presentation/screens/merchant_menu_screen.dart';
import '../../../orders/presentation/merchant/screens/merchant_home_screen.dart';
import '../../../profile/presentation/screens/merchant_profile_screen.dart';
import '../widgets/quick_eat_bottom_nav.dart';
import 'main_layout.dart';

class MerchantMainLayout extends StatelessWidget {
  const MerchantMainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      pages: [
        MerchantHomeScreen(),
        MerchantMenuScreen(),
        MerchantProfileScreen(),
      ],
      navItems: [
        QuickEatNavItem(
          label: 'Accueil',
          iconInactif: Icons.storefront_outlined,
          iconActif: Icons.storefront,
        ),
        QuickEatNavItem(
          label: 'Menus',
          iconInactif: Icons.restaurant_menu_outlined,
          iconActif: Icons.restaurant_menu,
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
