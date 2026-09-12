import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../mock/mock_data.dart';
import 'firestore_service.dart';

/// Insère les données fictives de [MockData] dans Firestore (projet fscamp-app)
/// uniquement si les collections sont vides. À n'utiliser qu'en développement.
Future<void> assurerSeedFirestore({FirebaseFirestore? firestore}) async {
  final db = firestore ?? FirebaseFirestore.instance;

  if (await _nonVide(db, FirestoreService.usersCollection) &&
      await _nonVide(db, FirestoreService.menusCollection) &&
      await _nonVide(db, FirestoreService.ordersCollection)) {
    return;
  }

  final batch = db.batch();
  for (final user in MockData.utilisateurs) {
    batch.set(
      db.collection(FirestoreService.usersCollection).doc(user.idUser),
      user.toMap(),
    );
  }
  for (final menu in MockData.plats) {
    batch.set(
      db.collection(FirestoreService.menusCollection).doc(menu.idFood),
      menu.toMap(),
    );
  }
  for (final commande in MockData.commandes) {
    batch.set(
      db.collection(FirestoreService.ordersCollection).doc(commande.idCommande),
      commande.toMap(),
    );
  }
  await batch.commit();
  debugPrint(
    'Seed Firestore effectué dans ${FirestoreService.ordersCollection}.',
  );
}

Future<bool> _nonVide(FirebaseFirestore db, String collection) async {
  final snap = await db.collection(collection).limit(1).get();
  return snap.docs.isNotEmpty;
}
