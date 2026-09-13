/// Plat proposé par un commerçant.
class FoodModel {
  final String idFood;
  final String nom;
  final String? description;
  final double prix;
  final String? imageUrl;
  final String categorie;
  final bool disponible;
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

  factory FoodModel.fromJson(Map<String, dynamic> json) =>
      FoodModel.fromMap(json, id: json['idFood'] as String? ?? '');

  Map<String, dynamic> toJson() => toMap();

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

  @override
  String toString() => 'FoodModel($nom — $prix FCFA)';
}
