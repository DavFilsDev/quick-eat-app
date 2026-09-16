import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../../data/repositories/order_repository.dart';
import '../../../../../data/repositories/user_repository.dart';
import '../../../../../models/enums/order_status.dart';
import '../../../../../models/order_model.dart';
import '../../../../../models/user_model.dart';

class MerchantOrdersController extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final UserRepository _userRepository;
  final String _merchantId;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;
  String? _errorMessage;

  MerchantOrdersController({
    required OrderRepository orderRepository,
    required UserRepository userRepository,
    required String merchantId,
  }) : _orderRepository = orderRepository,
       _userRepository = userRepository,
       _merchantId = merchantId {
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
    // Triée de la plus ancienne à la plus récente (ancienneté croissante)
    final sorted = List<OrderModel>.from(_allOrders);
    sorted.sort((a, b) => a.dateCommande.compareTo(b.dateCommande));
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
  }

  Future<UserModel?> getStudentInfo(String studentId) {
    return _userRepository.obtenirUtilisateur(studentId);
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
