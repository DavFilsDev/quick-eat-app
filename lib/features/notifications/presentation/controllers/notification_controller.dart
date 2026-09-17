import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../../models/notification_model.dart';

enum NotificationStatus { loading, success, error }

class NotificationController extends ChangeNotifier {
  NotificationController({
    required this._repository,
    required this._idUtilisateur,
  });

  final NotificationRepository _repository;
  final String _idUtilisateur;

  StreamSubscription<List<NotificationModel>>? _subscription;

  NotificationStatus _status = NotificationStatus.loading;
  List<NotificationModel> _notifications = const [];
  String? _errorMessage;

  NotificationStatus get status => _status;
  List<NotificationModel> get notifications => _notifications;
  String? get errorMessage => _errorMessage;

  int get nonLues => _notifications.where((n) => !n.estLue).length;

  void startListening() {
    _status = NotificationStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository
        .streamNotifications(_idUtilisateur)
        .listen(
          (notifications) {
            _notifications = notifications;
            _status = NotificationStatus.success;
            notifyListeners();
          },
          onError: (Object error) {
            _errorMessage = Failure.fromException(error).message;
            _status = NotificationStatus.error;
            notifyListeners();
          },
        );
  }

  Future<void> marquerCommeLue(String idNotification) async {
    try {
      await _repository.marquerCommeLue(
        idUtilisateur: _idUtilisateur,
        idNotification: idNotification,
      );
    } catch (error) {
      _errorMessage = Failure.fromException(error).message;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
