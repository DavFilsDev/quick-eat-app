/// Ligne d'une commande : un plat, sa quantité et son prix figé.
class OrderItemModel {
  final String idItem;
  final String idFood;
  final String nom;
  final int quantite;
  final double prixUnitaire;

  const OrderItemModel({
    this.idItem = '',
    required this.idFood,
    required this.nom,
    required this.quantite,
    required this.prixUnitaire,
  });

  double get sousTotal => quantite * prixUnitaire;

  factory OrderItemModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    return OrderItemModel(
      idItem: data['idItem'] as String? ?? id,
      idFood: data['idFood'] as String? ?? '',
      nom: data['nom'] as String? ?? '',
      quantite: data['quantite'] as int? ?? 1,
      prixUnitaire: (data['prixUnitaire'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idItem': idItem,
      'idFood': idFood,
      'nom': nom,
      'quantite': quantite,
      'prixUnitaire': prixUnitaire,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      OrderItemModel.fromMap(json, id: json['idItem'] as String? ?? '');

  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() => 'OrderItemModel($nom × $quantite)';
}
