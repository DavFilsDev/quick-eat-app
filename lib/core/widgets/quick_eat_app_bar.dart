import 'package:flutter/material.dart';

import '../../data/repositories/notification_repository.dart';
import '../../features/notifications/presentation/widgets/notification_bell.dart';
import '../constants/app_colors.dart';

class QuickEatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QuickEatAppBar({
    super.key,
    this.title = 'QuickEat',
    this.actions = const [],
    this.notificationRepository,
    this.idUtilisateur,
    this.onOuvrirCommandes,
    this.automaticallyImplyLeading = true,
  });

  final String title;

  final List<Widget> actions;

  final NotificationRepository? notificationRepository;

  final String? idUtilisateur;

  final VoidCallback? onOuvrirCommandes;

  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      actions: [
        ...actions,
        NotificationBell(
          idUtilisateur: idUtilisateur,
          notificationRepository: notificationRepository,
          onOuvrirCommandes: onOuvrirCommandes,
        ),
      ],
    );
  }
}
