import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/failures.dart';
import '../../models/enums/order_status.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';

abstract class OrderRepository {
  Stream<List<OrderModel>> streamCommandesEtudiant(String idEtudiant);
  Stream<List<OrderModel>> streamCommandesCommercant(String idCommercant);
  Future<String> creerCommande(OrderModel commande);
  Future<void> mettreAJourStatut(String idCommande, OrderStatus statut);
  Future<void> annulerCommande(String idCommande);
}

class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(FirestorePaths.orders);

  @override
  Stream<List<OrderModel>> streamCommandesEtudiant(String idEtudiant) => _orders
      .where('idEtudiant', isEqualTo: idEtudiant)
      .snapshots()
      .asyncMap(_avecItems);

  @override
  Stream<List<OrderModel>> streamCommandesCommercant(String idCommercant) =>
      _orders
          .where('idCommercant', isEqualTo: idCommercant)
          .snapshots()
          .asyncMap(_avecItems);

  @override
  Future<String> creerCommande(OrderModel commande) async {
    final docRef = _orders.doc();
    final batch = _firestore.batch();
    final data = commande.toMap()
      ..['idCommande'] = docRef.id
      ..remove('items');
    batch.set(docRef, data);
    for (final item in commande.items) {
      batch.set(
        docRef.collection(FirestorePaths.orderItems).doc(),
        item.toMap(),
      );
    }
    await batch.commit();
    return docRef.id;
  }

  @override
  Future<void> mettreAJourStatut(String idCommande, OrderStatus statut) async {
    if (idCommande.isEmpty) {
      throw const Failure('Commande introuvable.');
    }
    try {
      await _orders.doc(idCommande).set({
        'statut': statut.dbValue,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw Failure(
        'Impossible de mettre à jour le statut de la commande. Réessayez.',
        cause: e,
      );
    }
  }

  @override
  Future<void> annulerCommande(String idCommande) async {
    if (idCommande.isEmpty) {
      throw const Failure('Commande introuvable.');
    }
    final doc = await _orders.doc(idCommande).get();
    final data = doc.data();
    if (data == null) {
      throw const Failure('Commande introuvable.');
    }
    final statutActuel = OrderStatus.fromDbValue(
      data['statut'] as String? ?? '',
    );
    // Règle métier stricte du MCD : ANNULEE uniquement depuis EN_ATTENTE.
    if (statutActuel != OrderStatus.enAttente) {
      throw const InvalidOrderTransition(
        "Cette commande ne peut plus être annulée (préparation déjà lancée).",
      );
    }
    await mettreAJourStatut(idCommande, OrderStatus.annulee);
  }

  Future<List<OrderModel>> _avecItems(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) async {
    final commandes = <OrderModel>[];
    for (final doc in snap.docs) {
      final itemsSnap = await doc.reference
          .collection(FirestorePaths.orderItems)
          .get();
      final items = itemsSnap.docs
          .map(
            (itemDoc) => OrderItemModel.fromMap(itemDoc.data(), id: itemDoc.id),
          )
          .toList();
      commandes.add(
        OrderModel.fromMap(doc.data(), id: doc.id).copyWith(items: items),
      );
    }
    return commandes;
  }
}
