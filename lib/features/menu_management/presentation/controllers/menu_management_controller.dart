import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../data/repositories/menu_repository.dart';
import '../../../../models/food_model.dart';

enum MenuManagementStatus { loading, success, error }

class MenuManagementController extends ChangeNotifier {
  MenuManagementController({
    required this._menuRepository,
    required this._idCommercant,
  });

  final MenuRepository _menuRepository;
  final String _idCommercant;

  StreamSubscription<List<FoodModel>>? _subscription;
  MenuManagementStatus _status = MenuManagementStatus.loading;
  List<FoodModel> _plats = const [];
  String? _errorMessage;
  bool _isSaving = false;

  MenuManagementStatus get status => _status;
  List<FoodModel> get plats => _plats;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;

  void startListening() {
    _status = MenuManagementStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _menuRepository
        .streamMenusParCommercant(_idCommercant)
        .listen(
          (plats) {
            _plats = plats;
            _status = MenuManagementStatus.success;
            notifyListeners();
          },
          onError: (Object error) {
            _errorMessage = _messageFrom(error);
            _status = MenuManagementStatus.error;
            notifyListeners();
          },
        );
  }

  Future<bool> ajouter(FoodModel plat) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _menuRepository.creerMenu(
        FoodModel(
          idFood: plat.idFood,
          nom: plat.nom,
          description: plat.description,
          prix: plat.prix,
          imageUrl: plat.imageUrl,
          categorie: plat.categorie,
          disponible: plat.disponible,
          idCommercant: _idCommercant,
        ),
      );
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error);
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> modifier(FoodModel plat) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _menuRepository.mettreAJourMenu(plat);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error);
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> supprimer(String idFood) async {
    try {
      await _menuRepository.supprimerMenu(idFood);
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> basculerDisponibilite(FoodModel plat, bool disponible) async {
    try {
      await _menuRepository.changerDisponibilite(plat.idFood, disponible);
      return true;
    } catch (error) {
      _errorMessage = _messageFrom(error);
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
