import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../models/notification_model.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> streamNotifications(String idUtilisateur);
  Future<void> creerNotification(NotificationModel notification);
  Future<void> marquerCommeLue({
    required String idUtilisateur,
    required String idNotification,
  });
}

class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notifications(
    String idUtilisateur,
  ) => _firestore
      .collection(FirestorePaths.users)
      .doc(idUtilisateur)
      .collection(FirestorePaths.notifications);

  @override
  Stream<List<NotificationModel>> streamNotifications(String idUtilisateur) {
    return _notifications(idUtilisateur)
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  @override
  Future<void> creerNotification(NotificationModel notification) {
    final docRef = _notifications(notification.idUtilisateur).doc();
    final data = notification.toMap()..['idNotification'] = docRef.id;
    return docRef.set(data);
  }

  @override
  Future<void> marquerCommeLue({
    required String idUtilisateur,
    required String idNotification,
  }) {
    return _notifications(idUtilisateur)
        .doc(idNotification)
        .set({'estLue': true}, SetOptions(merge: true));
  }
}
