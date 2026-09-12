/// Ligne d'une commande : un plat avec sa quantité et son prix figé.
///
/// Stocké dans la sous-collection Firestore `orders/{orderId}/items`.
class OrderItemModel {
  /// Identifiant unique de la ligne.
  final String idItem;

  /// Identifiant du plat commandé (clé étrangère).
  final String idFood;

  /// Nom du plat (copie dénormalisée à la commande).
  final String nom;

  /// Quantité commandée.
  final int quantite;

  /// Prix unitaire en FCFA.
  final double prixUnitaire;

  const OrderItemModel({
    this.idItem = '',
    required this.idFood,
    required this.nom,
    required this.quantite,
    required this.prixUnitaire,
  });

  /// Total de la ligne : quantité × prix unitaire.
  double get sousTotal => quantite * prixUnitaire;

  /// Construit un [OrderItemModel] depuis un document Firestore.
  factory OrderItemModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    return OrderItemModel(
      idItem: data['idItem'] as String? ?? id,
      idFood: data['idFood'] as String? ?? '',
      nom: data['nom'] as String? ?? '',
      quantite: data['quantite'] as int? ?? 1,
      prixUnitaire: (data['prixUnitaire'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Convertit la ligne en document Firestore.
  Map<String, dynamic> toMap() {
    return {
      'idItem': idItem,
      'idFood': idFood,
      'nom': nom,
      'quantite': quantite,
      'prixUnitaire': prixUnitaire,
    };
  }

  /// Construit un [OrderItemModel] depuis un JSON (API REST).
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel.fromMap(json, id: json['idItem'] as String? ?? '');
  }

  /// Convertit la ligne en JSON (API REST).
  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() => 'OrderItemModel($nom × $quantite)';
}
