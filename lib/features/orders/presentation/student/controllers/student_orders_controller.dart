import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../data/repositories/order_repository.dart';
import '../../../../../models/enums/delivery_type.dart';
import '../../../../../models/enums/order_status.dart';
import '../../../../../models/food_model.dart';
import '../../../../../models/order_item_model.dart';
import '../../../../../models/order_model.dart';

enum StudentOrdersStatus { loading, success, error }

class StudentOrdersController extends ChangeNotifier {
  StudentOrdersController({
    required OrderRepository orderRepository,
    required String idEtudiant,
  }) : this._(orderRepository, idEtudiant);

  StudentOrdersController._(this._orderRepository, this._idEtudiant);

  final OrderRepository _orderRepository;
  final String _idEtudiant;

  StreamSubscription<List<OrderModel>>? _subscription;

  StudentOrdersStatus _status = StudentOrdersStatus.loading;
  List<OrderModel> _orders = const [];
  String? _errorMessage;

  bool _isCreatingOrder = false;
  String? _creationErrorMessage;

  StudentOrdersStatus get status => _status;
  List<OrderModel> get orders => _orders;
  String? get errorMessage => _errorMessage;
  bool get isCreatingOrder => _isCreatingOrder;
  String? get creationErrorMessage => _creationErrorMessage;

  void startListening() {
    _status = StudentOrdersStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _orderRepository
        .streamCommandesEtudiant(_idEtudiant)
        .listen(
          (orders) {
            _orders = orders;
            _status = StudentOrdersStatus.success;
            notifyListeners();
          },
          onError: (Object error) {
            _errorMessage = _messageFrom(error);
            _status = StudentOrdersStatus.error;
            notifyListeners();
          },
        );
  }

  Future<bool> creerCommande({
    required FoodModel food,
    required DeliveryType typeReception,
    required int quantite,
    String? adresseLivraison,
  }) async {
    _isCreatingOrder = true;
    _creationErrorMessage = null;
    notifyListeners();

    try {
      final item = OrderItemModel(
        idFood: food.idFood,
        nom: food.nom,
        quantite: quantite,
        prixUnitaire: food.prix,
      );

      final commande = OrderModel(
        idCommande: '',
        idEtudiant: _idEtudiant,
        idCommercant: food.idCommercant,
        dateCommande: DateTime.now(),
        montantTotal: item.sousTotal,
        typeReception: typeReception,
        adresseLivraison: typeReception == DeliveryType.livraison
            ? adresseLivraison
            : null,
        statut: OrderStatus.enAttente,
        items: [item],
      );

      await _orderRepository.creerCommande(commande);
      _isCreatingOrder = false;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _creationErrorMessage = Failure.fromException(e).message;
      _isCreatingOrder = false;
      notifyListeners();
      return false;
    } catch (e) {
      _creationErrorMessage = 'Une erreur est survenue. Réessayez.';
      _isCreatingOrder = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmerReception(String idCommande) async {
    try {
      await _orderRepository.mettreAJourStatut(idCommande, OrderStatus.livree);
      return true;
    } on FirebaseException catch (e) {
      _errorMessage = Failure.fromException(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> annulerCommande(String idCommande) async {
    try {
      await _orderRepository.annulerCommande(idCommande);
      return true;
    } on InvalidOrderTransition catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on FirebaseException catch (e) {
      _errorMessage = Failure.fromException(e).message;
      notifyListeners();
      return false;
    }
  }

  String _messageFrom(Object error) {
    if (error is FirebaseException) {
      return Failure.fromException(error).message;
    }
    return 'Une erreur est survenue. Réessayez.';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
