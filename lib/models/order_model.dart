import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums/delivery_type.dart';
import 'enums/order_status.dart';
import 'order_item_model.dart';

/// Modèle d'une commande passée par un étudiant.
///
/// Stocké dans la collection Firestore `orders` ; les lignes de la
/// commande sont dans la sous-collection `orders/{orderId}/items`.
class OrderModel {
  /// Identifiant unique (clé primaire).
  final String idCommande;

  /// Identifiant de l'étudiant qui passe la commande.
  final String idEtudiant;

  /// Identifiant du commerçant qui gère la commande.
  final String idCommercant;

  /// Date de la commande.
  final DateTime dateCommande;

  /// Montant total en FCFA.
  final double montantTotal;

  /// Mode de réception : livraison ou retrait.
  final DeliveryType typeReception;

  /// Adresse de retrait (si livraison).
  final String? adresseRetrait;

  /// Statut de la commande (suivi temps réel).
  final OrderStatus statut;

  /// Lignes de la commande.
  final List<OrderItemModel> items;

  const OrderModel({
    required this.idCommande,
    required this.idEtudiant,
    required this.idCommercant,
    required this.dateCommande,
    required this.montantTotal,
    required this.typeReception,
    this.adresseRetrait,
    this.statut = OrderStatus.enAttente,
    this.items = const [],
  });

  /// Construit un [OrderModel] depuis un document Firestore.
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
      adresseRetrait: data['adresseRetrait'] as String?,
      statut: OrderStatus.fromDbValue(data['statut'] as String? ?? ''),
      items: (data['items'] as List<dynamic>? ?? const [])
          .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convertit le modèle en document Firestore.
  Map<String, dynamic> toMap() {
    return {
      'idCommande': idCommande,
      'idEtudiant': idEtudiant,
      'idCommercant': idCommercant,
      'dateCommande': dateCommande,
      'montantTotal': montantTotal,
      'typeReception': typeReception.dbValue,
      'adresseRetrait': adresseRetrait,
      'statut': statut.dbValue,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  /// Construit un [OrderModel] depuis un JSON (API REST).
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel.fromMap(json, id: json['idCommande'] as String? ?? '');
  }

  /// Convertit le modèle en JSON (API REST).
  Map<String, dynamic> toJson() => toMap();

  /// Copie du modèle en modifiant certains champs.
  OrderModel copyWith({
    double? montantTotal,
    DeliveryType? typeReception,
    String? adresseRetrait,
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
      adresseRetrait: adresseRetrait ?? this.adresseRetrait,
      statut: statut ?? this.statut,
      items: items ?? this.items,
    );
  }

  /// Filtre les statuts visibles côté marchand selon le mode de réception.
  ///
  /// - Livraison : Accepter → Livraison (en cours de livraison)
  /// - Retrait : Accepter → Terminée
  List<OrderStatus> get statutsMarchand {
    return typeReception == DeliveryType.livraison
        ? const [
            OrderStatus.acceptee,
            OrderStatus.enCoursDeLivraison,
            OrderStatus.livree,
          ]
        : const [
            OrderStatus.acceptee,
            OrderStatus.terminee,
            OrderStatus.livree,
          ];
  }

  /// Parse une date venant de Firestore (Timestamp) ou d'un JSON (String).
  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString());
  }

  @override
  String toString() => 'OrderModel($idCommande — $statut)';
}
