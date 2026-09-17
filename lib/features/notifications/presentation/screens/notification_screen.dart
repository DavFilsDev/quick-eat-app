import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/time_ago_formatter.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../../models/notification_model.dart';
import '../controllers/notification_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    super.key,
    required this.idUtilisateur,
    this.notificationRepository,
  });

  final String idUtilisateur;
  final NotificationRepository? notificationRepository;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationController(
      repository:
          widget.notificationRepository ?? FirestoreNotificationRepository(),
      idUtilisateur: widget.idUtilisateur,
    )..startListening();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ouvrirNotification(NotificationModel notification) async {
    await _controller.marquerCommeLue(notification.idNotification);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          switch (_controller.status) {
            case NotificationStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case NotificationStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _controller.errorMessage ?? 'Erreur de chargement.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                ),
              );
            case NotificationStatus.success:
              final notifications = _controller.notifications;
              if (notifications.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucune notification pour le moment.',
                    style: AppTextStyles.body,
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationTile(
                    notification: notification,
                    onTap: () => _ouvrirNotification(notification),
                  );
                },
              );
          }
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nonLue = !notification.estLue;

    return Material(
      color: nonLue ? const Color(0xFFFFF1E6) : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: Key('notification_${notification.idNotification}'),
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: nonLue
                    ? AppColors.primary
                    : Colors.grey.shade200,
                child: Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: nonLue ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.titre,
                      style: TextStyle(
                        fontWeight: nonLue ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      TimeAgoFormatter.format(notification.dateCreation),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (nonLue)
                Container(
                  key: Key(
                    'notification_non_lue_${notification.idNotification}',
                  ),
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
