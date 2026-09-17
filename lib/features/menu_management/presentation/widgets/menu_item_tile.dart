import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../models/food_model.dart';

class MenuItemTile extends StatelessWidget {
  const MenuItemTile({
    super.key,
    required this.food,
    required this.onToggleDisponible,
    required this.onEditer,
    required this.onSupprimer,
  });

  final FoodModel food;
  final ValueChanged<bool> onToggleDisponible;
  final VoidCallback onEditer;
  final VoidCallback onSupprimer;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImagePlat(imageUrl: food.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          food.nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.heading2.copyWith(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatutDisponibilite(
                        disponible: food.disponible,
                        onChanged: onToggleDisponible,
                      ),
                    ],
                  ),
                  if ((food.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      food.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(food.prix),
                        style: AppTextStyles.price,
                      ),
                      const SizedBox(width: 8),
                      _CategorieChip(categorie: food.categorie),
                      const Spacer(),
                      IconButton(
                        key: Key('editer_${food.idFood}'),
                        onPressed: onEditer,
                        tooltip: 'Modifier',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        key: Key('supprimer_${food.idFood}'),
                        onPressed: onSupprimer,
                        tooltip: 'Supprimer',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.statusCancelled,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlat extends StatelessWidget {
  const _ImagePlat({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    const fallback = SizedBox(
      width: 72,
      height: 72,
      child: ColoredBox(
        color: AppColors.background,
        child: Icon(Icons.fastfood, color: AppColors.textSecondary),
      ),
    );

    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: url == null || url.isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: url,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              placeholder: (context, _) => fallback,
              errorWidget: (context, _, _) => fallback,
            ),
    );
  }
}

class _StatutDisponibilite extends StatelessWidget {
  const _StatutDisponibilite({
    required this.disponible,
    required this.onChanged,
  });

  final bool disponible;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          disponible ? 'Disponible' : 'Épuisé',
          style: AppTextStyles.caption.copyWith(
            color: disponible
                ? AppColors.statusAccepted
                : AppColors.statusCancelled,
            fontWeight: FontWeight.w600,
          ),
        ),
        Switch(
          value: disponible,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

class _CategorieChip extends StatelessWidget {
  const _CategorieChip({required this.categorie});

  final String categorie;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        categorie,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
