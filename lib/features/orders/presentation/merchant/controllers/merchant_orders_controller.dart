import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../../data/repositories/notification_repository.dart';
import '../../../../../data/repositories/order_repository.dart';
import '../../../../../data/repositories/user_repository.dart';
import '../../../../../models/enums/order_status.dart';
import '../../../../../models/notification_model.dart';
import '../../../../../models/order_model.dart';
import '../../../../../models/user_model.dart';

class MerchantOrdersController extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final UserRepository _userRepository;
  final NotificationRepository? _notificationRepository;
  final String _merchantId;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;
  String? _errorMessage;

  MerchantOrdersController({
    required this._orderRepository,
    required this._userRepository,
    required this._merchantId,
    this._notificationRepository,
  }) {
    _init();
  }

  void _init() {
    _ordersSubscription = _orderRepository
        .streamCommandesCommercant(_merchantId)
        .listen(
          (orders) {
            _allOrders = orders;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage =
                "Erreur lors de la récupération des commandes : $error";
            notifyListeners();
          },
        );
  }

  List<OrderModel> get orders {
    final sorted = List<OrderModel>.from(_allOrders);
    sorted.sort((a, b) => b.dateCommande.compareTo(a.dateCommande));
    return sorted;
  }

  int get enCoursCount {
    return _allOrders
        .where(
          (o) =>
              o.statut != OrderStatus.recu &&
              o.statut != OrderStatus.livree &&
              o.statut != OrderStatus.annulee,
        )
        .length;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _orderRepository.mettreAJourStatut(orderId, newStatus);
    } catch (e) {
      rethrow;
    }
    await _notifierStatutEtudiant(orderId, newStatus);
  }

  Future<void> _notifierStatutEtudiant(
    String orderId,
    OrderStatus newStatus,
  ) async {
    if (newStatus != OrderStatus.terminee &&
        newStatus != OrderStatus.enCoursDeLivraison) {
      return;
    }
    final repository = _notificationRepository;
    if (repository == null) return;

    final index = _allOrders.indexWhere((o) => o.idCommande == orderId);
    if (index == -1) return;
    final order = _allOrders[index];
    if (order.idEtudiant.isEmpty) return;

    final message = newStatus == OrderStatus.terminee
        ? 'Votre commande est prête à être retirée.'
        : 'Votre commande est en cours de livraison.';

    try {
      await repository.creerNotification(
        NotificationModel(
          idNotification: '',
          idUtilisateur: order.idEtudiant,
          titre: 'Mise à jour de commande',
          message: message,
          idCommande: orderId,
          dateCreation: DateTime.now(),
        ),
      );
    } catch (_) {
      return;
    }
  }

  Stream<UserModel?> streamStudentInfo(String studentId) {
    return _userRepository.streamUtilisateur(studentId);
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
