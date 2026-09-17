import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../../models/notification_model.dart';
import '../screens/notification_screen.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({
    super.key,
    this.idUtilisateur,
    this.notificationRepository,
    this.onOuvrirCommandes,
  });

  final String? idUtilisateur;
  final NotificationRepository? notificationRepository;
  final VoidCallback? onOuvrirCommandes;

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  String? _uid;
  NotificationRepository? _repository;
  Stream<List<NotificationModel>>? _stream;

  @override
  void initState() {
    super.initState();
    _uid = _resoudreUid();
    final uid = _uid;
    if (uid != null && uid.isNotEmpty) {
      _repository =
          widget.notificationRepository ?? FirestoreNotificationRepository();
      _stream = _repository!.streamNotifications(uid);
    }
  }

  String? _resoudreUid() {
    final fourni = widget.idUtilisateur;
    if (fourni != null && fourni.isNotEmpty) return fourni;
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ouvrir() async {
    final uid = _uid;
    final repository = _repository;
    if (uid == null || repository == null) return;

    final resultat = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NotificationScreen(
          idUtilisateur: uid,
          notificationRepository: repository,
        ),
      ),
    );
    if (resultat == true) {
      widget.onOuvrirCommandes?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stream == null) {
      return const IconButton(
        icon: Icon(Icons.notifications_outlined),
        onPressed: null,
      );
    }

    return StreamBuilder<List<NotificationModel>>(
      stream: _stream,
      builder: (context, snapshot) {
        final nonLues = (snapshot.data ?? const <NotificationModel>[])
            .where((n) => !n.estLue)
            .length;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              key: const Key('icone_notifications'),
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifications',
              onPressed: _ouvrir,
            ),
            if (nonLues > 0)
              Positioned(
                top: 6,
                right: 4,
                child: Container(
                  key: const Key('badge_notifications'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: BoxDecoration(
                    color: AppColors.statusCancelled,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    nonLues > 99 ? '99+' : '$nonLues',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
