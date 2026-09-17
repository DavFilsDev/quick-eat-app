import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/firestore_paths.dart';
import '../mock/mock_data.dart';

Future<void> assurerSeedFirestore({FirebaseFirestore? firestore}) async {
  final db = firestore ?? FirebaseFirestore.instance;

  if (await _nonVide(db, FirestorePaths.users) &&
      await _nonVide(db, FirestorePaths.menus) &&
      await _nonVide(db, FirestorePaths.orders)) {
    return;
  }

  final batch = db.batch();
  for (final user in MockData.utilisateurs) {
    batch.set(
      db.collection(FirestorePaths.users).doc(user.idUser),
      user.toMap(),
    );
  }
  for (final menu in MockData.plats) {
    batch.set(
      db.collection(FirestorePaths.menus).doc(menu.idFood),
      menu.toMap(),
    );
  }
  for (final commande in MockData.commandes) {
    batch.set(
      db.collection(FirestorePaths.orders).doc(commande.idCommande),
      commande.toMap(),
    );
  }
  await batch.commit();
  debugPrint('Seed Firestore effectué dans ${FirestorePaths.orders}.');
}

Future<bool> _nonVide(FirebaseFirestore db, String collection) async {
  final snap = await db.collection(collection).limit(1).get();
  return snap.docs.isNotEmpty;
}
