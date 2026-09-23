import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_image.dart';

class DishThumbnail extends StatelessWidget {
  const DishThumbnail({
    super.key,
    required this.imageUrl,
    this.size = 44,
    this.fallbackIcon = Icons.restaurant,
  });

  final String? imageUrl;
  final double size;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final defaut = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        fallbackIcon,
        size: size * 0.5,
        color: AppColors.textSecondary,
      ),
    );

    if (url == null || url.isEmpty) return defaut;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: AppImage(
          value: url,
          width: size,
          height: size,
          placeholder: defaut,
          errorWidget: defaut,
        ),
      ),
    );
  }
}
