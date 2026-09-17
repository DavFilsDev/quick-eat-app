import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.caption),
      subtitle: Text(
        value,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
