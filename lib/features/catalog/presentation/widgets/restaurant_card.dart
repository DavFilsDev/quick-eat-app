import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class RestaurantCard extends StatelessWidget {
  final String idCommercant;
  final String restaurantNom;
  final int nbPlats;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.idCommercant,
    required this.restaurantNom,
    required this.nbPlats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 60,
                height: 60,
                color: AppColors.background,
                child: const Icon(
                  Icons.storefront,
                  size: 30,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurantNom,
                    style: AppTextStyles.heading2.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$nbPlats plats disponibles',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: BorderSide(color: Colors.grey.shade300),
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text('Visiter'),
            ),
          ],
        ),
      ),
    );
  }
}
