/// Modèle d'un plat proposé par un commerçant.
///
/// Stocké dans la collection Firestore `menus`.
class FoodModel {
  /// Identifiant unique (clé primaire).
  final String idFood;

  /// Nom du plat.
  final String nom;

  /// Description du plat.
  final String? description;

  /// Prix en FCFA.
  final double prix;

  /// URL de la photo du plat.
  final String? imageUrl;

  /// Catégorie du plat (ex. : Fast Food, Boisson…).
  final String categorie;

  /// Disponibilité du plat.
  final bool disponible;

  /// Identifiant du commerçant propriétaire (clé étrangère).
  final String idCommercant;

  const FoodModel({
    required this.idFood,
    required this.nom,
    this.description,
    required this.prix,
    this.imageUrl,
    this.categorie = 'Autre',
    this.disponible = true,
    required this.idCommercant,
  });

  /// Construit un [FoodModel] depuis un document Firestore.
  factory FoodModel.fromMap(Map<String, dynamic> data, {required String id}) {
    return FoodModel(
      idFood: data['idFood'] as String? ?? id,
      nom: data['nom'] as String? ?? '',
      description: data['description'] as String?,
      prix: (data['prix'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] as String?,
      categorie: data['categorie'] as String? ?? 'Autre',
      disponible: data['disponible'] as bool? ?? true,
      idCommercant: data['idCommercant'] as String? ?? '',
    );
  }

  /// Convertit le modèle en document Firestore.
  Map<String, dynamic> toMap() {
    return {
      'idFood': idFood,
      'nom': nom,
      'description': description,
      'prix': prix,
      'imageUrl': imageUrl,
      'categorie': categorie,
      'disponible': disponible,
      'idCommercant': idCommercant,
    };
  }

  /// Construit un [FoodModel] depuis un JSON (API REST).
  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel.fromMap(json, id: json['idFood'] as String? ?? '');
  }

  /// Convertit le modèle en JSON (API REST).
  Map<String, dynamic> toJson() => toMap();

  /// Copie du modèle en modifiant certains champs.
  FoodModel copyWith({
    String? nom,
    String? description,
    double? prix,
    String? imageUrl,
    String? categorie,
    bool? disponible,
  }) {
    return FoodModel(
      idFood: idFood,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      imageUrl: imageUrl ?? this.imageUrl,
      categorie: categorie ?? this.categorie,
      disponible: disponible ?? this.disponible,
      idCommercant: idCommercant,
    );
  }

  // Écoute temps réel du document (bonus suivi en temps réel).
  @override
  String toString() => 'FoodModel($nom — $prix FCFA)';
}
