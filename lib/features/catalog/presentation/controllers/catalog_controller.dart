import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../data/repositories/menu_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../models/food_model.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({
    required this.menuRepository,
    required this.userRepository,
    this.idEtudiant,
  }) {
    _subscription = menuRepository.streamMenus().listen(_onMenus);
    _chargerCampusEtudiant();
  }

  final MenuRepository menuRepository;
  final UserRepository userRepository;
  final String? idEtudiant;

  StreamSubscription<List<FoodModel>>? _subscription;

  List<FoodModel> _tousLesPlats = [];
  List<FoodModel> _platsFiltres = [];
  String _recherche = '';
  String? _idCommercantSelectionne;
  String? _categorieSelectionnee;
  String? _campusSelectionne;

  bool _chargementCommercantsEnCours = false;
  bool _rechargerCommercants = false;
  bool _disposed = false;

  final Map<String, String> _nomsCommercants = {};

  final Map<String, String> _campusesCommercants = {};

  final Set<String> _commercantsCharges = {};

  String get campusSelectionne => _campusSelectionne ?? 'Tous';

  String get restaurantSelectionne => _idCommercantSelectionne == null
      ? 'Tous'
      : getNomRestaurant(_idCommercantSelectionne!);

  String get categorieSelectionnee => _categorieSelectionnee ?? 'Tous';

  List<FoodModel> get plats => _platsFiltres;

  List<String> get categories {
    final distinct = _tousLesPlats.map((m) => m.categorie).toSet().toList();
    distinct.sort();
    return ['Tous', ...distinct];
  }

  List<String> get restaurantsDisponibles {
    final ids = _tousLesPlats.map((m) => m.idCommercant).toSet().toList();
    if (_campusSelectionne == null) return ids;
    return ids
        .where((id) => _campusesCommercants[id] == _campusSelectionne)
        .toList();
  }

  String getNomRestaurant(String idCommercant) =>
      _nomsCommercants[idCommercant] ?? 'Restaurant';

  int nbPlatsRestaurant(String idCommercant) => _tousLesPlats
      .where((m) => m.idCommercant == idCommercant && m.disponible)
      .length;

  List<String> get nomsRestaurants {
    final noms = <String>{};
    for (final id in restaurantsDisponibles) {
      noms.add(getNomRestaurant(id));
    }
    final sorted = noms.toList()..sort();
    return ['Tous', ...sorted];
  }

  List<String> get nomsCampuses {
    final campuses = _campusesCommercants.values
        .where((c) => c.isNotEmpty)
        .toSet();
    final sorted = campuses.toList()..sort();
    return ['Tous', ...sorted];
  }

  void setCampusParNom(String? campus) {
    if (campus == null || campus == 'Tous') {
      _campusSelectionne = null;
    } else {
      _campusSelectionne = campus;
    }
    _applyFiltres();
    notifyListeners();
  }

  void setRestaurantParNom(String? nom) {
    if (nom == null || nom == 'Tous') {
      setCommercant(null);
      return;
    }
    String? id;
    for (final e in _nomsCommercants.entries) {
      if (e.value == nom) {
        id = e.key;
        break;
      }
    }
    setCommercant(id);
  }

  void _onMenus(List<FoodModel> plats) {
    _tousLesPlats = plats.where((m) => m.disponible).toList();
    _applyFiltres();
    _chargerCommercants();
  }

  Future<void> _chargerCampusEtudiant() async {
    final idEtudiant = this.idEtudiant;
    if (idEtudiant == null || idEtudiant.isEmpty) return;
    final user = await userRepository.obtenirUtilisateur(idEtudiant);
    if (user == null || user.campus.isEmpty) return;
    _campusSelectionne = user.campus;
    _applyFiltres();
    await _chargerCommercants();
  }

  Future<void> _chargerCommercants() async {
    if (_chargementCommercantsEnCours) {
      _rechargerCommercants = true;
      return;
    }
    _chargementCommercantsEnCours = true;
    do {
      _rechargerCommercants = false;
      final ids = _tousLesPlats.map((m) => m.idCommercant).toSet();
      for (final id in ids) {
        if (_commercantsCharges.contains(id)) continue;
        final user = await userRepository.obtenirUtilisateur(id);
        _commercantsCharges.add(id);
        if (user != null) {
          _nomsCommercants[id] = user.nomComplet;
          if (user.campus.isNotEmpty) {
            _campusesCommercants[id] = user.campus;
          }
        }
      }
    } while (_rechargerCommercants);
    _chargementCommercantsEnCours = false;
    _applyFiltres();
  }

  void setRecherche(String value) {
    _recherche = value;
    _applyFiltres();
  }

  void setCategorie(String? categorie) {
    _categorieSelectionnee = categorie;
    _applyFiltres();
  }

  void setCommercant(String? id) {
    _idCommercantSelectionne = id;
    _applyFiltres();
  }

  void _applyFiltres() {
    if (_disposed) return;
    _platsFiltres = _tousLesPlats.where((m) {
      if (_idCommercantSelectionne != null &&
          m.idCommercant != _idCommercantSelectionne) {
        return false;
      }
      if (_campusSelectionne != null &&
          _campusesCommercants[m.idCommercant] != _campusSelectionne) {
        return false;
      }
      if (_categorieSelectionnee != null &&
          _categorieSelectionnee != 'Tous' &&
          m.categorie != _categorieSelectionnee) {
        return false;
      }
      if (_recherche.isNotEmpty &&
          !m.nom.toLowerCase().contains(_recherche.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
