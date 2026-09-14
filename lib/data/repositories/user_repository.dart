import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../models/user_model.dart';

/// Contrat d'accès aux documents `users/{userId}`.
abstract class UserRepository {
  Stream<UserModel?> streamUtilisateur(String idUser);
  Future<UserModel?> obtenirUtilisateur(String idUser);
  Future<void> creerOuMettreAJourUtilisateur(UserModel user);
}

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestorePaths.users);

  @override
  Stream<UserModel?> streamUtilisateur(String idUser) {
    return _users
        .doc(idUser)
        .snapshots()
        .map(
          (doc) =>
              doc.exists ? UserModel.fromMap(doc.data()!, id: doc.id) : null,
        );
  }

  @override
  Future<UserModel?> obtenirUtilisateur(String idUser) async {
    final doc = await _users.doc(idUser).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, id: doc.id);
  }

  @override
  Future<void> creerOuMettreAJourUtilisateur(UserModel user) =>
      _users.doc(user.idUser).set(user.toMap());
}
