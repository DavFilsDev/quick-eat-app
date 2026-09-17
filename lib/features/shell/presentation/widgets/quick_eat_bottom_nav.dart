import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class QuickEatNavItem {
  const QuickEatNavItem({
    required this.label,
    required this.iconInactif,
    required this.iconActif,
  });

  final String label;
  final IconData iconInactif;
  final IconData iconActif;
}

class QuickEatBottomNav extends StatelessWidget {
  const QuickEatBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<QuickEatNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Color(0xFFE8E8EC), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: AppColors.surface,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          showUnselectedLabels: true,
          items: [
            for (final item in items)
              BottomNavigationBarItem(
                icon: Icon(item.iconInactif),
                activeIcon: Icon(item.iconActif),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}
