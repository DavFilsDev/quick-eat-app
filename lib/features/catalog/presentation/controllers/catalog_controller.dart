import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../data/repositories/menu_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../models/food_model.dart';

/// Contrôleur gérant l'état et les filtres de l'écran Accueil Étudiant
/// et de l'écran Détail Restaurant.
/// Les catégories et les noms de restaurants sont dynamiques (depuis Firestore).
class CatalogController extends ChangeNotifier {
  CatalogController({
    required this.menuRepository,
    required this.userRepository,
  }) {
    _subscription = menuRepository.streamMenus().listen(_onMenus);
    _chargerCommercants();
  }

  final MenuRepository menuRepository;
  final UserRepository userRepository;

  StreamSubscription<List<FoodModel>>? _subscription;

  List<FoodModel> _tousLesPlats = [];
  List<FoodModel> _platsFiltres = [];
  String _recherche = '';
  String? _idCommercantSelectionne;
  String? _categorieSelectionnee;
  String? _campusSelectionne;

  /// Noms des commerçants résolus (idCommercant → nom).
  final Map<String, String> _nomsCommercants = {};

  /// Campus des commerçants résolus (idCommercant → campus).
  final Map<String, String> _campusesCommercants = {};

  List<FoodModel> get plats => _platsFiltres;

  /// Catégories dynamiques extraites des FoodModel.categorie.
  List<String> get categories {
    final distinct = _tousLesPlats.map((m) => m.categorie).toSet().toList();
    distinct.sort();
    return ['Tous', ...distinct];
  }

  /// Liste des restaurants (idCommercant) pour les chips de filtre.
  /// Respecte le campus sélectionné si un campus est actif.
  List<String> get restaurantsDisponibles {
    final ids = _tousLesPlats.map((m) => m.idCommercant).toSet().toList();
    if (_campusSelectionne == null) return ids;
    return ids
        .where((id) => _campusesCommercants[id] == _campusSelectionne)
        .toList();
  }

  /// Nom d'un restaurant par son idCommercant.
  String getNomRestaurant(String idCommercant) =>
      _nomsCommercants[idCommercant] ?? 'Restaurant';

  /// Nombre de plats disponibles pour un restaurant donné.
  int nbPlatsRestaurant(String idCommercant) => _tousLesPlats
      .where((m) => m.idCommercant == idCommercant && m.disponible)
      .length;

  /// Liste des noms de restaurants distincts (chips de l'Accueil).
  List<String> get nomsRestaurants {
    final noms = <String>{};
    for (final id in restaurantsDisponibles) {
      noms.add(getNomRestaurant(id));
    }
    final sorted = noms.toList()..sort();
    return ['Tous', ...sorted];
  }

  /// Liste des campus distincts des commerçants (chips de filtre de l'Accueil).
  List<String> get nomsCampuses {
    final campuses = _campusesCommercants.values
        .where((c) => c.isNotEmpty)
        .toSet();
    final sorted = campuses.toList()..sort();
    return ['Tous', ...sorted];
  }

  /// Définit le campus filtré (null ou 'Tous' remet tous les restaurants).
  void setCampusParNom(String? campus) {
    if (campus == null || campus == 'Tous') {
      _campusSelectionne = null;
    } else {
      _campusSelectionne = campus;
    }
    _applyFiltres();
    notifyListeners();
  }

  /// Définit le restaurant filtré via son nom (null remet 'Tous').
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
    notifyListeners();
  }

  Future<void> _chargerCommercants() async {
    final ids = _tousLesPlats.map((m) => m.idCommercant).toSet().toList();
    for (final id in ids) {
      final user = await userRepository.obtenirUtilisateur(id);
      if (user != null) {
        _nomsCommercants[id] = user.nomComplet;
        if (user.campus.isNotEmpty) {
          _campusesCommercants[id] = user.campus;
        }
      }
    }
    notifyListeners();
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
    _subscription?.cancel();
    super.dispose();
  }
}
