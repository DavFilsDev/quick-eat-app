import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums/user_role.dart';

/// Modèle d'un utilisateur (étudiant ou commerçant).
class UserModel {
  final String idUser;
  final String prenoms;
  final String nom;
  final String email;
  final String? telephone;
  final UserRole role;
  final String? photoUrl;
  final String campus;
  final DateTime? dateCreation;

  const UserModel({
    required this.idUser,
    required this.prenoms,
    required this.nom,
    required this.email,
    this.telephone,
    this.role = UserRole.student,
    this.photoUrl,
    required this.campus,
    this.dateCreation,
  });

  String get nomComplet => '$prenoms $nom'.trim();

  factory UserModel.fromMap(Map<String, dynamic> data, {required String id}) {
    return UserModel(
      idUser: data['idUser'] as String? ?? id,
      prenoms: data['prenoms'] as String? ?? '',
      nom: data['nom'] as String? ?? '',
      email: data['email'] as String? ?? '',
      telephone: data['telephone'] as String?,
      role: UserRole.fromDbValue(data['role'] as String? ?? 'STUDENT'),
      photoUrl: data['photoUrl'] as String?,
      campus: data['campus'] as String? ?? '',
      dateCreation: _parseDate(data['dateCreation']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'prenoms': prenoms,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'role': role.dbValue,
      'photoUrl': photoUrl,
      'campus': campus,
      'dateCreation': dateCreation,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel.fromMap(json, id: json['idUser'] as String? ?? '');

  Map<String, dynamic> toJson() => toMap();

  UserModel copyWith({
    String? prenoms,
    String? nom,
    String? email,
    String? telephone,
    UserRole? role,
    String? photoUrl,
    String? campus,
    DateTime? dateCreation,
  }) {
    return UserModel(
      idUser: idUser,
      prenoms: prenoms ?? this.prenoms,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      campus: campus ?? this.campus,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  // Firestore renvoie un Timestamp, le JSON une String ISO.
  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString());
  }

  @override
  String toString() => 'UserModel($nomComplet — $role — $campus)';
}
