import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../models/food_model.dart';

abstract class MenuRepository {
  Stream<List<FoodModel>> streamMenus();
  Stream<List<FoodModel>> streamMenusParCommercant(String idCommercant);
  Future<String> creerMenu(FoodModel menu);
  Future<void> mettreAJourMenu(FoodModel menu);
  Future<void> supprimerMenu(String idMenu);
  Future<void> changerDisponibilite(String idMenu, bool disponible);
}

class FirestoreMenuRepository implements MenuRepository {
  FirestoreMenuRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _menus =>
      _firestore.collection(FirestorePaths.menus);

  @override
  Stream<List<FoodModel>> streamMenus() => _menus.snapshots().map(
    (snap) => snap.docs
        .map((doc) => FoodModel.fromMap(doc.data(), id: doc.id))
        .toList(),
  );

  @override
  Stream<List<FoodModel>> streamMenusParCommercant(String idCommercant) =>
      _menus
          .where('idCommercant', isEqualTo: idCommercant)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((doc) => FoodModel.fromMap(doc.data(), id: doc.id))
                .toList(),
          );

  @override
  Future<String> creerMenu(FoodModel menu) async {
    final doc = await _menus.add(menu.toMap());
    return doc.id;
  }

  @override
  Future<void> mettreAJourMenu(FoodModel menu) =>
      _menus.doc(menu.idFood).update(menu.toMap());

  @override
  Future<void> supprimerMenu(String idMenu) => _menus.doc(idMenu).delete();

  @override
  Future<void> changerDisponibilite(String idMenu, bool disponible) =>
      _menus.doc(idMenu).update({'disponible': disponible});
}
