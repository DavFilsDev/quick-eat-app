import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Indicateur de chargement standard — utiliser partout où un Stream/Future
/// est en attente plutôt que de recréer un CircularProgressIndicator ad-hoc.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
