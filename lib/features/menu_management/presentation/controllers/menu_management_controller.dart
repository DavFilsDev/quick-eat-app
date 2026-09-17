import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../data/repositories/menu_repository.dart';
import '../../../../models/food_model.dart';

enum MenuManagementStatus { loading, success, error }

enum MenuTri { prixCroissant, prixDecroissant }

class MenuManagementController extends ChangeNotifier {
  MenuManagementController({
    required this._menuRepository,
    required this._idCommercant,
  });

  final MenuRepository _menuRepository;
  final String _idCommercant;

  StreamSubscription<List<FoodModel>>? _subscription;
  MenuManagementStatus _status = MenuManagementStatus.loading;
  List<FoodModel> _tousLesPlats = const [];
  String? _errorMessage;
  bool _isSaving = false;

  String _recherche = '';
  String? _categorieSelectionnee;
  MenuTri? _tri;

  MenuManagementStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;

  String get recherche => _recherche;
  String? get categorieSelectionnee => _categorieSelectionnee;
  MenuTri? get tri => _tri;

  bool get aDesPlats => _tousLesPlats.isNotEmpty;

  List<FoodModel> get plats {
    final filtres = _tousLesPlats.where((plat) {
      if (_categorieSelectionnee != null &&
          _categorieSelectionnee != 'Tous' &&
          plat.categorie != _categorieSelectionnee) {
        return false;
      }
      if (_recherche.isNotEmpty &&
          !plat.nom.toLowerCase().contains(_recherche.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    final tri = _tri;
    if (tri != null) {
      filtres.sort(
        (a, b) => tri == MenuTri.prixCroissant
            ? a.prix.compareTo(b.prix)
            : b.prix.compareTo(a.prix),
      );
    }
    return filtres;
  }

  List<String> get categories {
    final distinct =
        _tousLesPlats.map((plat) => plat.categorie).toSet().toList()..sort();
    return ['Tous', ...distinct];
  }

  void setRecherche(String value) {
    _recherche = value;
    notifyListeners();
  }

  void setCategorie(String? categorie) {
    _categorieSelectionnee = categorie;
    notifyListeners();
  }

  void setTri(MenuTri? tri) {
    _tri = tri;
    notifyListeners();
  }

  void startListening() {
    _status = MenuManagementStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _menuRepository
        .streamMenusParCommercant(_idCommercant)
        .listen(
          (plats) {
            _tousLesPlats = plats;
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
