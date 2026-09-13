import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/enums/order_status.dart';
import '../models/food_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

/// Point d'accès aux données QuickEat stockées dans Firestore (projet fscamp-app).
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String usersCollection = 'users';
  static const String menusCollection = 'menus';
  static const String ordersCollection = 'orders';

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(usersCollection);

  CollectionReference<Map<String, dynamic>> get _menus =>
      _firestore.collection(menusCollection);

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(ordersCollection);

  Stream<List<UserModel>> streamUtilisateurs() => _users.snapshots().map(
    (snap) => snap.docs
        .map((doc) => UserModel.fromMap(doc.data(), id: doc.id))
        .toList(),
  );

  Stream<List<FoodModel>> streamMenus() => _menus.snapshots().map(
    (snap) => snap.docs
        .map((doc) => FoodModel.fromMap(doc.data(), id: doc.id))
        .toList(),
  );

  Stream<List<OrderModel>> streamCommandes() => _orders.snapshots().map(
    (snap) => snap.docs
        .map((doc) => OrderModel.fromMap(doc.data(), id: doc.id))
        .toList(),
  );

  Stream<List<OrderModel>> streamCommandesEtudiant(String idEtudiant) => _orders
      .where('idEtudiant', isEqualTo: idEtudiant)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => OrderModel.fromMap(doc.data(), id: doc.id))
            .toList(),
      );

  Future<void> ajouterOuMettreAJourUtilisateur(UserModel user) =>
      _users.doc(user.idUser).set(user.toMap());

  Future<String> creerCommande(OrderModel commande) async {
    await _orders.doc(commande.idCommande).set(commande.toMap());
    return commande.idCommande;
  }

  Future<void> mettreAJourStatutCommande(
    String idCommande,
    OrderStatus statut,
  ) => _orders.doc(idCommande).update({'statut': statut.dbValue});

  Future<void> annulerCommande(String idCommande) =>
      mettreAJourStatutCommande(idCommande, OrderStatus.annulee);
}
