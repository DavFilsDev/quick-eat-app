import 'package:flutter/material.dart';

import '../widgets/quick_eat_bottom_nav.dart';

/// Coquille d'écran principale avec navigation inférieure (Étudiant ou
/// Commerçant).
///
/// `IndexedStack` conserve l'état des onglets (aucune reconstruction au
/// changement d'onglet). Les sous-pages (`Détail Restaurant`, `Détails
/// Commande`, ...) ainsi que les modales (`CreateOrderModal`, ...) se
/// poussent au-dessus via `Navigator.push` / `showModalBottomSheet`,
/// par-dessus cette coquille — la barre de navigation n'est donc jamais
/// dupliquée dans une sous-page.
class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    required this.pages,
    required this.navItems,
    this.initialIndex = 0,
  });

  final List<Widget> pages;
  final List<QuickEatNavItem> navItems;
  final int initialIndex;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: widget.pages),
      bottomNavigationBar: QuickEatBottomNav(
        items: widget.navItems,
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
      ),
    );
  }
}
