import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../models/food_model.dart';

class FoodCard extends StatelessWidget {
  final FoodModel food;
  final VoidCallback? onCommander;

  const FoodCard({super.key, required this.food, this.onCommander});

  @override
  Widget build(BuildContext context) {
    final isDisponible = food.disponible;
    final description = food.description;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.nom,
                    style: AppTextStyles.heading2.copyWith(fontSize: 16),
                  ),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(food.prix),
                        style: AppTextStyles.price,
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: isDisponible ? onCommander : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Commander'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppImage(
                value: food.imageUrl ?? '',
                width: 80,
                height: 80,
                errorWidget: Container(
                  width: 80,
                  height: 80,
                  color: AppColors.background,
                  child: const Icon(
                    Icons.fastfood,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
