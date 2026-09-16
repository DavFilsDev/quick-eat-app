import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/repositories/order_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../models/enums/delivery_type.dart';
import '../../models/enums/order_status.dart';
import '../../models/enums/user_role.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';

Future<void> devAutoLogin({
  required String role,
  required UserRepository userRepository,
}) async {
  final String email = 'dev.$role@quickeat.local';
  const String password = 'dev12345';
  final auth = FirebaseAuth.instance;

  UserCredential credential;
  try {
    credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException {
    credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  final uid = credential.user!.uid;
  await userRepository.creerOuMettreAJourUtilisateur(
    UserModel(
      idUser: uid,
      prenoms: 'Dev',
      nom: role == 'merchant' ? 'Test Commerçant' : 'Test Étudiant',
      email: email,
      telephone: '+22900000000',
      role: role == 'merchant' ? UserRole.merchant : UserRole.student,
      campus: 'Campus UAC - Abomey-Calavi',
      dateCreation: DateTime.now(),
    ),
  );

  if (role == 'merchant') {
    await _seedOrdersPourCommercantDev(uid, FirebaseFirestore.instance);
  }
}

Future<void> _seedOrdersPourCommercantDev(
  String merchantId,
  FirebaseFirestore db,
) async {
  final existing = await db
      .collection('orders')
      .where('idCommercant', isEqualTo: merchantId)
      .limit(1)
      .get();
  if (existing.docs.isNotEmpty) return;

  final repo = FirestoreOrderRepository(firestore: db);

  // 1. En attente (livraison)
  await repo.creerCommande(
    OrderModel(
      idCommande: 'dev-order-1',
      idEtudiant: 'user-001',
      idCommercant: merchantId,
      dateCommande: DateTime.now().subtract(const Duration(minutes: 25)),
      montantTotal: 2700,
      typeReception: DeliveryType.livraison,
      adresseLivraison: 'Résidence Campus Ngoa, chambre 12',
      statut: OrderStatus.enAttente,
      items: const [
        OrderItemModel(
          idFood: 'food-001',
          nom: 'Burger Poulet',
          quantite: 1,
          prixUnitaire: 1500,
        ),
        OrderItemModel(
          idFood: 'food-002',
          nom: 'Sandwich Döner',
          quantite: 1,
          prixUnitaire: 1200,
        ),
      ],
    ),
  );

  // 2. Acceptée (retrait)
  await repo.creerCommande(
    OrderModel(
      idCommande: 'dev-order-2',
      idEtudiant: 'user-002',
      idCommercant: merchantId,
      dateCommande: DateTime.now().subtract(const Duration(minutes: 55)),
      montantTotal: 2400,
      typeReception: DeliveryType.retrait,
      statut: OrderStatus.acceptee,
      items: const [
        OrderItemModel(
          idFood: 'food-002',
          nom: 'Sandwich Döner',
          quantite: 2,
          prixUnitaire: 1200,
        ),
      ],
    ),
  );

  // 3. Terminée (retrait) → teste le bouton "Passer à : Reçue"
  await repo.creerCommande(
    OrderModel(
      idCommande: 'dev-order-3',
      idEtudiant: 'user-001',
      idCommercant: merchantId,
      dateCommande: DateTime.now().subtract(const Duration(minutes: 90)),
      montantTotal: 1500,
      typeReception: DeliveryType.retrait,
      statut: OrderStatus.terminee,
      items: const [
        OrderItemModel(
          idFood: 'food-001',
          nom: 'Burger Poulet',
          quantite: 1,
          prixUnitaire: 1500,
        ),
      ],
    ),
  );
}
