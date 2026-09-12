import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums/delivery_type.dart';
import 'enums/order_status.dart';
import 'order_item_model.dart';

/// Modèle d'une commande.
///
/// Stockée dans Firestore `orders` ; ses lignes sont dans la
/// sous-collection `orders/{orderId}/items`.
class OrderModel {
  final String idCommande;
  final String idEtudiant;
  final String idCommercant;
  final DateTime dateCommande;
  final double montantTotal;
  final DeliveryType typeReception;
  final String? adresseLivraison;
  final OrderStatus statut;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.idCommande,
    required this.idEtudiant,
    required this.idCommercant,
    required this.dateCommande,
    required this.montantTotal,
    required this.typeReception,
    this.adresseLivraison,
    this.statut = OrderStatus.enAttente,
    this.items = const [],
  });

  factory OrderModel.fromMap(Map<String, dynamic> data, {required String id}) {
    return OrderModel(
      idCommande: data['idCommande'] as String? ?? id,
      idEtudiant: data['idEtudiant'] as String? ?? '',
      idCommercant: data['idCommercant'] as String? ?? '',
      dateCommande: _parseDate(data['dateCommande']) ?? DateTime.now(),
      montantTotal: (data['montantTotal'] as num?)?.toDouble() ?? 0,
      typeReception: DeliveryType.fromDbValue(
        data['typeReception'] as String? ?? '',
      ),
      adresseLivraison: data['adresseLivraison'] as String?,
      statut: OrderStatus.fromDbValue(data['statut'] as String? ?? ''),
      items: (data['items'] as List<dynamic>? ?? const [])
          .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idCommande': idCommande,
      'idEtudiant': idEtudiant,
      'idCommercant': idCommercant,
      'dateCommande': dateCommande,
      'montantTotal': montantTotal,
      'typeReception': typeReception.dbValue,
      'adresseLivraison': adresseLivraison,
      'statut': statut.dbValue,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      OrderModel.fromMap(json, id: json['idCommande'] as String? ?? '');

  Map<String, dynamic> toJson() => toMap();

  OrderModel copyWith({
    double? montantTotal,
    DeliveryType? typeReception,
    String? adresseLivraison,
    OrderStatus? statut,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      idCommande: idCommande,
      idEtudiant: idEtudiant,
      idCommercant: idCommercant,
      dateCommande: dateCommande,
      montantTotal: montantTotal ?? this.montantTotal,
      typeReception: typeReception ?? this.typeReception,
      adresseLivraison: adresseLivraison ?? this.adresseLivraison,
      statut: statut ?? this.statut,
      items: items ?? this.items,
    );
  }

  // Workflow marchand :
  // - Livraison : ACCEPTEE → EN_COURS_DE_LIVRAISON → LIVREE
  // - Retrait : ACCEPTEE → TERMINEE → RECU
  List<OrderStatus> get statutsMarchand {
    return typeReception == DeliveryType.livraison
        ? const [
            OrderStatus.acceptee,
            OrderStatus.enCoursDeLivraison,
            OrderStatus.livree,
          ]
        : const [OrderStatus.acceptee, OrderStatus.terminee, OrderStatus.recu];
  }

  // Règle métier : l'annulation n'est autorisée qu'en EN_ATTENTE, avant
  // lancement de la préparation par le commerçant.
  bool get peutEtreAnnulee => statut == OrderStatus.enAttente;

  // Firestore renvoie un Timestamp, le JSON une String ISO.
  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString());
  }

  @override
  String toString() => 'OrderModel($idCommande — $statut)';
}
