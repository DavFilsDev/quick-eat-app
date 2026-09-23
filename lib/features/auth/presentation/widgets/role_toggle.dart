import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/enums/user_role.dart';

class RoleToggle extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const RoleToggle({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      isEmpty: false,
      decoration: const InputDecoration(
        labelText: 'Sélectionne ton profil',
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildOption(
              label: 'Étudiant',
              icon: Icons.person_outline,
              isSelected: selectedRole == UserRole.student,
              onTap: () => onRoleChanged(UserRole.student),
            ),
          ),
          Expanded(
            child: _buildOption(
              label: 'Commerçant',
              icon: Icons.storefront,
              isSelected: selectedRole == UserRole.merchant,
              onTap: () => onRoleChanged(UserRole.merchant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
