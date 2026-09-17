import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String idNotification;
  final String idUtilisateur;
  final String titre;
  final String message;
  final String? idCommande;
  final bool estLue;
  final DateTime dateCreation;

  const NotificationModel({
    required this.idNotification,
    required this.idUtilisateur,
    required this.titre,
    required this.message,
    this.idCommande,
    this.estLue = false,
    required this.dateCreation,
  });

  factory NotificationModel.fromMap(
    Map<String, dynamic> data, {
    required String id,
  }) {
    return NotificationModel(
      idNotification: data['idNotification'] as String? ?? id,
      idUtilisateur: data['idUtilisateur'] as String? ?? '',
      titre: data['titre'] as String? ?? '',
      message: data['message'] as String? ?? '',
      idCommande: data['idCommande'] as String?,
      estLue: data['estLue'] as bool? ?? false,
      dateCreation: _parseDate(data['dateCreation']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idNotification': idNotification,
      'idUtilisateur': idUtilisateur,
      'titre': titre,
      'message': message,
      'idCommande': idCommande,
      'estLue': estLue,
      'dateCreation': dateCreation,
    };
  }

  NotificationModel copyWith({bool? estLue}) {
    return NotificationModel(
      idNotification: idNotification,
      idUtilisateur: idUtilisateur,
      titre: titre,
      message: message,
      idCommande: idCommande,
      estLue: estLue ?? this.estLue,
      dateCreation: dateCreation,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString());
  }

  @override
  String toString() => 'NotificationModel($idNotification — $titre)';
}
