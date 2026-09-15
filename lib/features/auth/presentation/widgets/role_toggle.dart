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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sélectionne ton profil',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChip(
              label: 'Étudiant',
              isSelected: selectedRole == UserRole.student,
              onTap: () => onRoleChanged(UserRole.student),
            ),
            const SizedBox(width: 12),
            _buildChip(
              label: 'Commerçant',
              isSelected: selectedRole == UserRole.merchant,
              onTap: () => onRoleChanged(UserRole.merchant),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.primary,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
