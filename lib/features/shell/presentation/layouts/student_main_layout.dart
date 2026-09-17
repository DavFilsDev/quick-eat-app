import 'package:flutter/material.dart';

import '../../../catalog/presentation/screens/student_home_screen.dart';
import '../../../orders/presentation/student/screens/student_orders_screen.dart';
import '../../../profile/presentation/screens/student_profile_screen.dart';
import '../widgets/quick_eat_bottom_nav.dart';
import 'main_layout.dart';

class StudentMainLayout extends StatelessWidget {
  const StudentMainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      pages: [
        StudentHomeScreen(),
        StudentOrdersScreen(),
        StudentProfileScreen(),
      ],
      navItems: [
        QuickEatNavItem(
          label: 'Accueil',
          iconInactif: Icons.home_outlined,
          iconActif: Icons.home,
        ),
        QuickEatNavItem(
          label: 'Commandes',
          iconInactif: Icons.receipt_long_outlined,
          iconActif: Icons.receipt_long,
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
