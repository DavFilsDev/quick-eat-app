import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.photoUrl;

    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primary,
          child: ClipOval(
            child: photoUrl == null || photoUrl.isEmpty
                ? _Initiales(nom: user.nomComplet)
                : CachedNetworkImage(
                    imageUrl: photoUrl,
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    placeholder: (context, _) =>
                        _Initiales(nom: user.nomComplet),
                    errorWidget: (context, _, _) =>
                        _Initiales(nom: user.nomComplet),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(user.nomComplet, style: AppTextStyles.heading1),
        const SizedBox(height: 6),
        _RoleBadge(label: user.role.label),
        if (user.email.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(user.email, style: AppTextStyles.caption),
        ],
        if ((user.telephone ?? '').isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(user.telephone!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}

class _Initiales extends StatelessWidget {
  const _Initiales({required this.nom});

  final String nom;

  @override
  Widget build(BuildContext context) {
    final parties = nom.trim().split(RegExp(r'\s+'));
    final initiales = parties
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      color: AppColors.primary,
      child: initiales.isEmpty
          ? const Icon(Icons.person, color: Colors.white, size: 40)
          : Text(
              initiales,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
