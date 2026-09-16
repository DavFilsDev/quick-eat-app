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

/// État de chargement de la liste des commandes de l'étudiant.
enum StudentOrdersStatus { loading, success, error }

/// Contrôleur de l'écran "Mes Commandes" et de la modale de création.
///
/// Deux responsabilités volontairement regroupées ici (imposé par la
/// répartition des tâches en un seul fichier `controllers`) :
/// - écoute temps réel des commandes de l'étudiant (`startListening`),
///   utilisée par `StudentOrdersScreen`
/// - création d'une commande + actions ponctuelles (annulation,
///   confirmation de réception), utilisées par `CreateOrderModal` et par
///   les cartes de commande
///
/// Aucune règle métier n'est recalculée ici : `peutEtreAnnulee` et
/// `statutsMarchand` restent dans `OrderModel`, les transitions de statut
/// et le refus d'annulation hors `EN_ATTENTE` restent dans
/// `OrderRepository`. Ce contrôleur ne fait que relayer les appels et
/// exposer un état Loading/Success/Error explicite aux widgets.
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

  /// Démarre l'écoute temps réel des commandes de l'étudiant
  /// (`streamCommandesEtudiant`). À appeler une seule fois, typiquement
  /// dans le `create` du provider de `StudentOrdersScreen` — la modale de
  /// création n'en a pas besoin et ne doit pas l'appeler.
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

  /// Crée une commande pour [food] en quantité [quantite], avec le mode de
  /// réception [typeReception]. Retourne `true` si la création a réussi.
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

  /// L'étudiant confirme la réception d'une commande livrée
  /// (`EN_COURS_DE_LIVRAISON → LIVREE`). Pour le retrait, l'étudiant n'a
  /// aucune action : c'est le commerçant qui confirme `RECU` (Dev 4).
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

  /// Annule une commande. Le repository refuse déjà si le statut n'est plus
  /// `EN_ATTENTE` (`InvalidOrderTransition`) — le widget ne fait que
  /// relayer le résultat ; `peutEtreAnnulee` sert uniquement à masquer le
  /// bouton côté UI, ce n'est pas la source de vérité de la règle.
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
